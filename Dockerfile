FROM golang:alpine AS builder

RUN apk update && apk add --no-cache ca-certificates && update-ca-certificates

WORKDIR /go

ARG BUILD_VERSION

RUN go install github.com/xvzc/SpoofDPI/cmd/spoofdpi@v${BUILD_VERSION}

FROM scratch

EXPOSE 8080

COPY --from=builder /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/
COPY --from=builder /etc/passwd /etc/passwd
COPY --from=builder /etc/group /etc/group
COPY config.json /config.json
COPY --from=builder /go/bin/spoofdpi /go/bin/spoofdpi

CMD ["/go/bin/spoofdpi", "-addr=0.0.0.0", "-port=8180", "-dns-addr=1.1.1.1", "-timeout=500", "-window-size=0"]
# CMD ["/go/bin/spoof-dpi", "-addr=${ADDRESS} -debug=${DEBUG} -dns-addr=${DNS} -port=${PORT} -no-banner=${NO_BANNER} -timeout=${TIMEOUT} -window-size=${WINDOW_SIZE} $(echo \"${URLS}\" | tr -d ' ' | tr ',' '\n' | sed -e 's/^/-url=/') -pattern ${PATTERN}"]


ARG BUILD_ARCH
ARG BUILD_DATE
ARG BUILD_REF
ARG BUILD_VERSION

# Labels
LABEL \
    io.hass.name="ha-spoofdpi" \
    io.hass.description="ha-spoofdpi" \
    io.hass.arch="${BUILD_ARCH}" \
    io.hass.version="${BUILD_VERSION}" \
    io.hass.type="addon" \
    maintainer="ad <github@apatin.ru>" \
    org.label-schema.description="ha-spoofdpi" \
    org.label-schema.build-date=${BUILD_DATE} \
    org.label-schema.name="ha-spoofdpi" \
    org.label-schema.schema-version="1.0" \
    org.label-schema.usage="https://gitlab.com/ad/ha-spoofdpi/-/blob/master/README.md" \
    org.label-schema.vcs-ref=${BUILD_REF} \
    org.label-schema.vcs-url="https://github.com/ad/ha-spoofdpi/" \
    org.label-schema.vendor="HomeAssistant add-ons by ad"
