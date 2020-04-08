#### OKHttp的一些默认设置

 * The maximum number of requests for each host to execute concurrently. This limits requests by
 * the URL's host name. Note that concurrent requests to a single IP address may still exceed this
 * limit: multiple hostnames may share an IP address or be routed through the same HTTP proxy.
一个host同时最多5个请求  var maxRequestsPerHost = 5

同时最多有64个请求 var maxRequests = 64