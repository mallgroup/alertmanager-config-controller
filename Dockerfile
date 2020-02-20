FROM golang:1.13.8-alpine3.10 as builder

WORKDIR /src
COPY . .
RUN CGO_ENABLED=0 GOOS=linux go build -a -ldflags '-extldflags "-static"' -mod vendor -o alertmanager-config-controller github.com/dbsystel/alertmanager-config-controller/cmd

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
