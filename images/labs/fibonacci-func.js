/**
 * Your HTTP handling function, invoked with each request. This is an example
 * function that echoes its input to the caller, and logs the input to the console.
 *
 * It can be invoked with 'func invoke'
 * It can be tested with 'npm test'
 *
 * @param {Context} context a context object.
 * @param {object} context.body the request body if any
 * @param {object} context.query the query string deserialized as an object, if any
 * @param {object} context.log logging object with methods for 'info', 'warn', 'error', etc.
 * @param {object} context.headers the HTTP request headers
 * @param {string} context.method the HTTP request method
 * @param {string} context.httpVersion the HTTP protocol version
 * @param {string} context.httpVersionMajor the HTTP protocol major version number
 * @param {string} context.httpVersionMinor the HTTP protocol minor version number
 */

function fibonacci(n) {
  if (n <= 0) return 0;
  if (n === 1) return 1;
  
  let a = 0, b = 1;
  for (let i = 2; i <= n; i++) {
    [a, b] = [b, a + b];
  }
  return b;
}

const handle = async (context) => {
  context.log.info("Fibonacci function invoked", context);
  
  // Get the number from query parameter or request body
  const n = context.query.n || context.body?.n;
  
  if (!n) {
    return {
      statusCode: 400,
      body: JSON.stringify({
        error: "Missing parameter 'n'. Please provide a number to calculate Fibonacci.",
        example: "?n=10 or POST with body: {\"n\": 10}"
      }) + '\n'
    };
  }
  
  const num = parseInt(n);
  
  if (isNaN(num)) {
    return {
      statusCode: 400,
      body: JSON.stringify({
        error: "Parameter 'n' must be a valid integer",
        provided: n
      }) + '\n'
    };
  }
  
  if (num < 0) {
    return {
      statusCode: 400,
      body: JSON.stringify({
        error: "Parameter 'n' must be non-negative",
        provided: num
      }) + '\n'
    };
  }
  
  if (num > 100) {
    return {
      statusCode: 400,
      body: JSON.stringify({
        error: "Parameter 'n' must be 100 or less (to prevent timeouts)",
        provided: num
      }) + '\n'
    };
  }
  
  const result = fibonacci(num);
  
  return {
    statusCode: 200,
    body: JSON.stringify({
      input: num,
      fibonacci: result,
      message: `The ${num}th Fibonacci number is ${result}`
    }) + '\n'
  };
};

module.exports = { handle };