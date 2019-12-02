FROM golang:1.12.0-alpine3.10 as builder

WORKDIR /src
COPY . .
RUN CGO_ENABLED=0 GOOS=linux go build -a -ldflags '-extldflags "-static"' -mod vendor -o alertmanager-config-controller .

FROM alpine:3.10

RUN apk update \
    && apk add --no-cache curl \
                          ca-certificates \
                          tzdata \
    && update-ca-certificates

RUN addgroup -S kube-operator && adduser -S -g kube-operator kube-operator
USER kube-operator

COPY --from=builder /src/gitlab-exporter /bin/gitlab-exporter

ENTRYPOINT ["/bin/alertmanager-config-controller"]
