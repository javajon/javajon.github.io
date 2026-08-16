#!/bin/bash
# Apply the source edits this lab asks the LEARNER to type, for the test harness only.
#
#   plugin-edits.sh 8      the pod list run() implementation, and its imports
#   plugin-edits.sh 9      the --status flag
#   plugin-edits.sh 10     the run2() REST client implementation
#   plugin-edits.sh 11     the pod add implementation
#
# WHY THIS EXISTS
#
# Steps 7 to 11 teach plugin development by having the learner write Go, using {{open}} and
# {{copy}} macros against an IDE. A browser-driven harness cannot type into that IDE, so it
# skips the macros - and then runs the step's test commands against untouched source. The
# lab failed at step 9 with
#
#   go run cmd/kubectl-example/main.go pod list --status=true
#   Error: unknown flag: --status
#
# a correct command against a file the learner was supposed to have changed. Nothing was
# wrong with the lab; the edits simply had not happened.
#
# Each step declares data-test-edit="bash /opt/plugin-edits.sh N", so the harness performs
# the same change the prose describes. The learner never sees this file and still types the
# code themselves.
#
# RULES FOR EDITING THIS FILE
#
# 1. The edits are CUMULATIVE. Step 9's flag is useless without step 8's run() body, and
#    upstream ships that as a stub printing "add pod list code using direct object
#    references". Never reorder them.
# 2. Every edit must be IDEMPOTENT. A retry, or a step revisited, must not double-apply.
#    Each function checks for its own marker first and exits 0 if the work is already done.
# 3. The code inserted here must MATCH the code in the step markdown. If you change one,
#    change the other, or the harness proves something the learner is not being taught.
# 4. Get a substitution wrong and the Go stops compiling, which fails the lab in a way that
#    looks like a lab defect rather than a harness defect. `verify` builds after every
#    step for exactly that reason.
set -uo pipefail

LIST=pkg/example/cmd/pod_list.go
ADD=pkg/example/cmd/pod_add.go

die() { echo "plugin-edits: $*" >&2; exit 1; }

verify() {
  # Build after every edit. A syntax error introduced here would otherwise surface as the
  # NEXT command failing, which reads as a defect in the lab's own instructions.
  go build ./... || die "the edited source does not compile after step $1"
  echo "plugin-edits: step $1 applied and the project builds"
}

step8() {
  grep -q 'podsClient.List' "$LIST" && { echo "plugin-edits: step 8 already applied"; return 0; }
  [ -f "$LIST" ] || die "$LIST not found - is the working directory the cloned k8s-cli?"

  python3 - "$LIST" <<'PY'
import sys
p = sys.argv[1]
s = open(p).read()

# Imports, added to the existing block exactly as the step's first code snippet shows.
s = s.replace(
    '\t"github.com/spf13/cobra"\n)',
    '\t"github.com/spf13/cobra"\n\n'
    '\tapiv1 "k8s.io/api/core/v1"\n'
    '\tmetav1 "k8s.io/apimachinery/pkg/apis/meta/v1"\n\n'
    '\t"github.com/codementor/k8s-cli/pkg/example/env"\n)', 1)

# The run() body. The placeholder Printf goes; `return nil` stays as the last line.
old = ('func (p *podListCmd) run() error {\n\n'
       '\tfmt.Printf("add pod list code using direct object references\\n")\n'
       '\treturn nil\n}')
new = '''func (p *podListCmd) run() error {

\t// Acquire a kube client and a pods client
\tclient := env.NewClientSet(&Settings)
\tpodsClient := client.CoreV1().Pods(apiv1.NamespaceDefault)

\t// Query pod clients for a list of pods
\tlist, err := podsClient.List(metav1.ListOptions{})
\tif err != nil {
\t\treturn err
\t}

\tif len(list.Items) == 0 {
\t\tfmt.Printf("No Pods discovered.\\n")
\t\treturn nil
\t}

\tfor _, item := range list.Items {
\t\tfmt.Fprintf(p.out, "Pod %v in Namespace: %v\\n", item.Name, item.Namespace)
\t}

\treturn nil
}'''
if old not in s:
    raise SystemExit("step 8: the run() placeholder is not where it was expected")
s = s.replace(old, new, 1)
open(p, 'w').write(s)
PY
  [ $? -eq 0 ] || die "step 8 edit failed"
  verify 8
}

step9() {
  grep -q '"status", "i"' "$LIST" && { echo "plugin-edits: step 9 already applied"; return 0; }

  python3 - "$LIST" <<'PY'
import sys
p = sys.argv[1]
s = open(p).read()

# The struct field, at the marker the step names.
s = s.replace('\t// status boolean\n', '\t// status boolean\n\tstatus bool\n', 1)

# The flag, in BOTH newPodListCmd and newPodList2Cmd - the step says both, and missing one
# leaves `pod list2 --status` failing in a way that looks unrelated.
flag = ('\t// status flag\n'
        '\tf := cmd.Flags()\n'
        '\tf.BoolVarP(&pkg.status, "status", "i", true, "display status info")\n')
n = s.count('\t// status flag\n')
if n != 2:
    raise SystemExit(f"step 9: expected 2 status flag markers, found {n}")
s = s.replace('\t// status flag\n', flag)

# The listing loop becomes status-aware.
old = ('\tfor _, item := range list.Items {\n'
       '\t\tfmt.Fprintf(p.out, "Pod %v in Namespace: %v\\n", item.Name, item.Namespace)\n'
       '\t}')
new = '''\tfor _, item := range list.Items {
\t\tif p.status {
\t\t\tfmt.Fprintf(p.out, "pod %v in namespace: %v, status: %v\\n", item.Name, item.Namespace, item.Status.Phase)
\t\t} else {
\t\t\tfmt.Fprintf(p.out, "Pod %v in Namespace: %v\\n", item.Name, item.Namespace)
\t\t}
\t}'''
if old not in s:
    raise SystemExit("step 9: the run() listing loop from step 8 is not present")
s = s.replace(old, new, 1)
open(p, 'w').write(s)
PY
  [ $? -eq 0 ] || die "step 9 edit failed"
  verify 9
}

step10() {
  grep -q 'NewRestClient' "$LIST" && { echo "plugin-edits: step 10 already applied"; return 0; }

  python3 - "$LIST" <<'PY'
import sys
p = sys.argv[1]
s = open(p).read()

old = ('func (p *podListCmd) run2() error {\n\n'
       '\t//REST Client approach\n\n'
       '\tfmt.Printf("add pod list code using the rest client\\n")\n'
       '\treturn nil\n}')
new = '''func (p *podListCmd) run2() error {

\t//REST Client approach
\tclient := env.NewRestClient(&Settings)
\tresult := &apiv1.PodList{}

\terr := client.Get().
\t\tNamespace(apiv1.NamespaceDefault).
\t\tResource("pods").
\t\tDo().
\t\tInto(result)
\tif err != nil {
\t\treturn err
\t}

\tfmt.Fprintf(p.out, "RESTifarian technique\\n")
\tif len(result.Items) == 0 {
\t\tfmt.Printf("no pods discovered\\n")
\t\treturn nil
\t}
\tfor _, item := range result.Items {
\t\tfmt.Fprintf(p.out, "Pod %v in Namespace: %v\\n", item.Name, item.Namespace)
\t}

\treturn nil
}'''
if old not in s:
    raise SystemExit("step 10: the run2() placeholder is not where it was expected")
s = s.replace(old, new, 1)
open(p, 'w').write(s)
PY
  [ $? -eq 0 ] || die "step 10 edit failed"
  verify 10
}

step11() {
  grep -q 'podsClient.Create' "$ADD" && { echo "plugin-edits: step 11 already applied"; return 0; }
  [ -f "$ADD" ] || die "$ADD not found"

  python3 - "$ADD" <<'PY'
import sys
p = sys.argv[1]
s = open(p).read()

s = s.replace(
    '\t"github.com/spf13/cobra"\n)',
    '\t"github.com/spf13/cobra"\n\n'
    '\tapiv1 "k8s.io/api/core/v1"\n'
    '\tmetav1 "k8s.io/apimachinery/pkg/apis/meta/v1"\n\n'
    '\t"github.com/codementor/k8s-cli/pkg/example/env"\n)', 1)

old = '\tfmt.Printf("adding a pod\\n")\n\treturn nil\n}'
new = '''\tclient := env.NewClientSet(&Settings)
\tpodsClient := client.CoreV1().Pods(apiv1.NamespaceDefault)

\tpod := &apiv1.Pod{
\t\tObjectMeta: metav1.ObjectMeta{
\t\t\tName:   name,
\t\t\tLabels: map[string]string{"app": "demo"},
\t\t},
\t\tSpec: apiv1.PodSpec{
\t\t\tContainers: []apiv1.Container{
\t\t\t\t{
\t\t\t\t\tName:  name,
\t\t\t\t\tImage: p.image,
\t\t\t\t},
\t\t\t},
\t\t},
\t}

\tpp, err := podsClient.Create(pod)
\tif err != nil {
\t\treturn err
\t}

\tfmt.Fprintf(p.out, "Pod %v created with rev: %v\\n", pp.Name, pp.ResourceVersion)
\treturn nil
}'''
if old not in s:
    raise SystemExit("step 11: the run() placeholder is not where it was expected")
s = s.replace(old, new, 1)
open(p, 'w').write(s)
PY
  [ $? -eq 0 ] || die "step 11 edit failed"
  verify 11
}

case "${1:-}" in
  8)  step8 ;;
  9)  step9 ;;
  10) step10 ;;
  11) step11 ;;
  *)  die "usage: plugin-edits.sh 8|9|10|11" ;;
esac
