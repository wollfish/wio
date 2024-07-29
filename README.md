# wio

WIO is a micro web server for static assets, best fitted for serving react projects

---

## Build Docker Image

```shell
docker buildx create --use

docker buildx build --platform linux/amd64,linux/arm64 -t wollfish/wio --push .
```

---
