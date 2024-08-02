# Kong Custom Plugin

**Note: This code is based on the blog [here](https://konghq.com/blog/engineering/custom-authentication-and-authorization-framework-with-kong)**

## Installing Custom Plugin - DB

```sh
docker-compose up -d
```

#### To rebuild an image after making changes to authservice etc
```sh
docker-compose down
docker-compose up --build
```

- Add a service

```sh
http POST http://localhost:8001/services name=example-service url=https://httpbin.org/anything
```

- Add a Route to the Service

```sh
http POST http://localhost:8001/services/example-service/routes name=example-route paths:='["/echo"]'
```

- Add Plugin to the Service

```sh
http -f http://localhost:8001/services/example-service/plugins name=myplugin \
    config.authentication_url=http://authservice:8080/auth/validate/token \
    config.authorization_url=http://authservice:8080/auth/validate/customer
```

### Test

__1. Go to the authservice/ authservice.py and notice a few key details in the code between lines 9-18:__
- valid authentication bearer token value can only be "token1"
- if you input any value outside of "token1" you get authentication error (401 error code)
- for token1 bearer token, token1 are entitled to 2 scopes and requires 1 of these 2 scopes in the url parameter:
  - custId1
  - custId2

__Remember to check the plugin if it was configured via docker-compose and ensure it is pointing to authservice:8080 endpoint__

```sh
# 401 error code
http POST http://localhost:8000/echo

# 403 error code
http POST http://localhost:8000/echo "Authorization: Bearer token1"

# 200 success code
http POST http://localhost:8000/echo?custId=custId1 "Authorization: Bearer token1"
```

Response:

```sh
HTTP/1.1 200 OK
Access-Control-Allow-Credentials: true
Access-Control-Allow-Origin: *
Connection: keep-alive
Content-Length: 448
Content-Type: application/json
Date: Wed, 30 Jun 2021 07:28:16 GMT
Server: gunicorn/19.9.0
Via: kong/2.4.1
X-Kong-Proxy-Latency: 95
X-Kong-Upstream-Latency: 605

{
    "args": {},
    "data": "",
    "files": {},
    "form": {},
    "headers": {
        "Host": "httpbin.org",
        "User-Agent": "HTTPie/1.0.3",
        "X-Amzn-Trace-Id": "Root=1-60dc1d10-242220940c8f35971d00d4a3",
        "X-Forwarded-Host": "localhost",
        "X-Forwarded-Path": "/echo/anything",
        "X-Forwarded-Prefix": "/echo"
    },
    "json": null,
    "method": "GET",
    "origin": "127.0.0.1, 223.196.168.24",
    "url": "http://localhost/anything"
}
```

## Auth Service

```bash
http http://localhost:30000/auth/validate/token "Authorization: Bearer token1"
http http://localhost:30000/auth/validate/customer?custId=customer1
```
