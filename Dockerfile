FROM golang:alpine as builder

RUN apk update && apk add --no-cache ca-certificates && update-ca-certificates

WORKDIR /go

RUN go install github.com/xvzc/SpoofDPI/cmd/spoof-dpi@latest

FROM scratch

EXPOSE 8080

COPY --from=builder /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/
COPY --from=builder /etc/passwd /etc/passwd
COPY --from=builder /etc/group /etc/group
COPY config.json /config.json
COPY --from=builder /go/bin/spoof-dpi /go/bin/spoof-dpi

ENTRYPOINT ["/go/bin/spoof-dpi"]


ARG BUILD_ARCH
ARG BUILD_DATE
ARG BUILD_REF
ARG BUILD_VERSION

# Labels
LABEL \
    io.hass.name="ha-spoofDPI" \
    io.hass.description="ha-spoofDPI" \
    io.hass.arch="${BUILD_ARCH}" \
    io.hass.version="${BUILD_VERSION}" \
    io.hass.type="addon" \
    maintainer="ad <github@apatin.ru>" \
    org.label-schema.description="ha-spoofDPI" \
    org.label-schema.build-date=${BUILD_DATE} \
    org.label-schema.name="ha-spoofDPI" \
    org.label-schema.schema-version="1.0" \
    org.label-schema.usage="https://gitlab.com/ad/ha-spoofDPI/-/blob/master/README.md" \
    org.label-schema.vcs-ref=${BUILD_REF} \
    org.label-schema.vcs-url="https://github.com/ad/ha-spoofDPI/" \
    org.label-schema.vendor="HomeAssistant add-ons by ad"
