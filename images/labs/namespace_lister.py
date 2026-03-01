from kubernetes import client, config
import time
import datetime
import html

def create_html_file(namespaces_with_labels, error_message=None):
    html_content = """
    <!DOCTYPE html>
    <html>
    <head>
        <title>Kubernetes Namespace Dashboard</title>
        <style>
            body {
                font-family: Arial, sans-serif;
                max-width: 1000px;
                margin: 0 auto;
                padding: 20px;
            }
            h1 {
                color: #326ce5;
            }
            table {
                border-collapse: collapse;
                width: 100%;
                margin-top: 20px;
            }
            th, td {
                border: 1px solid #ddd;
                padding: 8px;
                text-align: left;
                vertical-align: top;
            }
            th {
                background-color: #f2f2f2;
            }
            .error-message {
                background-color: #f8d7da;
                color: #721c24;
                padding: 10px;
                border-radius: 5px;
                border-left: 4px solid #f5c6cb;
                margin: 10px 0;
            }
            .update-time {
                color: #6c757d;
                font-size: 0.8em;
                text-align: right;
                margin-top: 20px;
            }
            pre {
                margin: 0;
                white-space: pre-wrap;
                word-wrap: break-word;
            }
        </style>
    </head>
    <body>
        <h1>Kubernetes Namespace Dashboard</h1>
    """

    if error_message:
        html_content += f"""
        <div class="error-message">
            <strong>Error:</strong> {html.escape(error_message)}
        </div>
        """
    else:
        html_content += """
        <table>
            <tr>
                <th>Namespace</th>
                <th>Labels</th>
            </tr>
        """
        for ns_name, labels in namespaces_with_labels:
            labels_str = "<pre>" + html.escape("\n".join(f"{k}: {v}" for k, v in labels.items())) + "</pre>" if labels else "<i>No labels</i>"
            html_content += f"""
            <tr>
                <td>{html.escape(ns_name)}</td>
                <td>{labels_str}</td>
            </tr>
            """
        html_content += "</table>"

    current_time = datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    html_content += f"""
        <div class="update-time">
            Last updated: {current_time}
        </div>
    </body>
    </html>
    """

    with open("/app/html/index.html", "w") as file:
        file.write(html_content)

    print(f"HTML file updated at {current_time}")

def main():
    print("Namespace lister starting...")
    while True:
        try:
            config.load_incluster_config()
            v1 = client.CoreV1Api()
            namespace_list = v1.list_namespace()
            namespaces = [(ns.metadata.name, ns.metadata.labels or {}) for ns in namespace_list.items]
            create_html_file(namespaces)
        except client.rest.ApiException as e:
            error_message = f"Forbidden - permission denied: {e}"
            print(error_message)
            create_html_file([], error_message)
        except Exception as e:
            error_message = f"An error occurred: {str(e)}"
            print(error_message)
            create_html_file([], error_message)
        time.sleep(30)
        
if __name__ == "__main__":
    main()
