FROM golang:1.20 as builder

ENV GO111MODULE=on
ENV CGO_ENABLED=1
ENV GOOS=linux

WORKDIR /workspace

# Copy the Go Modules manifests
COPY go.mod go.mod
COPY go.sum go.sum

# cache deps before building and copying source so that we don't need to re-download as much
# and so that source changes don't invalidate our downloaded layer
RUN go mod download

# Copy the go source
COPY main.go main.go
COPY Makefile Makefile

# Build
RUN make && \
    ldd ./libobjectfs.so

# Use distroless as minimal base image to package the manager binary
# Refer to https://github.com/GoogleContainerTools/distroless for more details
FROM gcr.io/distroless/static:nonroot
WORKDIR /

COPY --from=builder /workspace/libobjectfs.h /libobjectfs.h
COPY --from=builder /workspace/libobjectfs.a /libobjectfs.a
COPY --from=builder /workspace/libobjectfs.so /libobjectfs.so

USER nonroot:nonroot
