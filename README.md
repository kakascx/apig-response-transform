# Inspur apig-response-transform
Kong plugin to transform the response

##Configuration
### Enabling the plugin on a Route
Configure this plugin on a route by adding this section do your declarative configuration file:

```
plugins:
- name: kong-plugin-template-transformer
  route: {route}
  config: 
    format: {one_of{xml,json}}
```

### Parameters

```
name            apig-response-transform
config.format   the response format wanted
```

### Example

- declarative configuration file

```
services:
- name: trans-service
  url: http://httpbin.org/json

routes:
- name: trans-routes
  service: trans-service
  paths:
  - /trans-json

plugins:
- name: apig-response-transform
  route: trans-routes
  config:
   format: xml
```

- Send a http request
```
$curl -i -X GET http://localhost:8000/trans-json
```

- Resule
Before transform:
```
HTTP/1.1 200 OK
Content-Type: application/json
Content-Length: 429
Connection: keep-alive
Access-Control-Allow-Credentials: true
Access-Control-Allow-Origin: *
Date: Thu, 27 Jun 2019 06:47:26 GMT
Referrer-Policy: no-referrer-when-downgrade
Server: nginx
X-Content-Type-Options: nosniff
X-Frame-Options: DENY
X-XSS-Protection: 1; mode=block
X-Kong-Upstream-Latency: 4107
X-Kong-Proxy-Latency: 152
Via: kong/1.1.2

{
  "slideshow": {
    "author": "Yours Truly", 
    "date": "date of publication", 
    "slides": [
      {
        "title": "Wake up to WonderWidgets!", 
        "type": "all"
      }, 
      {
        "items": [
          "Why <em>WonderWidgets</em> are great", 
          "Who <em>buys</em> WonderWidgets"
        ], 
        "title": "Overview", 
        "type": "all"
      }
    ], 
    "title": "Sample Slide Show"
  }
}
```
After transform

```
HTTP/1.1 200 OK
Content-Type: application/xml
Transfer-Encoding: chunked
Connection: keep-alive
Access-Control-Allow-Credentials: true
Access-Control-Allow-Origin: *
Date: Thu, 27 Jun 2019 06:48:27 GMT
Referrer-Policy: no-referrer-when-downgrade
Server: nginx
X-Content-Type-Options: nosniff
X-Frame-Options: DENY
X-XSS-Protection: 1; mode=block
X-Kong-Upstream-Latency: 2127
X-Kong-Proxy-Latency: 138
Via: kong/1.1.2

<Slideshow>
	<Slides>
		<Type>all</Type>
		<Title>Wake up to WonderWidgets!</Title>
	</Slides>
	<Slides>
 		<Title>Overview</Title>
		<Type>all</Type>
		<Items>
			Why <em>WonderWidgets</em> are great
 		</Items>
		<Items>
 			Who <em>buys</em> WonderWidgets
 		</Items>
 	</Slides>
 	<Author>Yours Truly</Author>
	<Date>date of publication</Date>
	<Title>Sample Slide Show</Title>
</Slideshow>
```
