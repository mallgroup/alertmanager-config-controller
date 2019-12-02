FROM golang:1.12.13-alpine3.10 as builder

RUN apk update \
    && apk add --no-cache git

WORKDIR /src
COPY . .
RUN CGO_ENABLED=0 GOOS=linux go mod vendor
RUN CGO_ENABLED=0 GOOS=linux go build -a -ldflags '-extldflags "-static"' -mod vendor -o alertmanager-config-controller ./cmd

FROM alpine:3.10

RUN apk update \
    && apk add --no-cache curl \
                          ca-certificates \
                          tzdata \
    && update-ca-certificates

RUN addgroup -S kube-operator && adduser -S -g kube-operator kube-operator
USER kube-operator

COPY --from=builder /src/alertmanager-config-controller /bin/alertmanager-config-controller

ENTRYPOINT ["/bin/alertmanager-config-controller"]
