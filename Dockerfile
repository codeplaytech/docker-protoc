FROM golang:1.20.1-bullseye AS plugin

ARG protoc_version=3.19.6
ARG protoc_url=https://github.com/protocolbuffers/protobuf/releases/download/v${protoc_version}/protoc-${protoc_version}-linux-x86_64.zip
ARG goproxy=direct

ENV GOPROXY=${goproxy}
ENV GOPATH=/gopath/

# install go code generator(compatibility).
# https://developers.google.com/protocol-buffers/docs/reference/go/faq
RUN git clone https://github.com/cupen/protoactor-go -b master --depth=1 \
    && cd ./protoactor-go/protobuf/protoc-gen-gograinv2 \
    && make install
RUN go install github.com/gogo/protobuf/protoc-gen-gogoslick@v1.2.1 \
    && go install google.golang.org/protobuf/cmd/protoc-gen-go@latest


FROM python:3.9-slim-bullseye AS protoc
ARG protoc_version=3.17.3
ARG protoc_url=https://github.com/protocolbuffers/protobuf/releases/download/v${protoc_version}/protoc-${protoc_version}-linux-x86_64.zip

ADD ${protoc_url} /protoc_bin/protoc.zip
RUN ls -ahl /protoc_bin/protoc.zip
RUN python -c "import zipfile; zf = zipfile.ZipFile('/protoc_bin/protoc.zip', 'r'); zf.extractall('/protoc_bin/'); zf.close()" \
    && chmod -R 755 /protoc_bin/

FROM debian:bullseye-slim AS runtime
COPY --from=protoc /protoc_bin/             /usr/
COPY --from=plugin /gopath/bin/protoc-gen-* /usr/bin/


# install third-party protos
ADD https://raw.githubusercontent.com/asynkron/protoactor-go/dev/actor/actor.proto    /usr/include/github.com/asynkron/protoactor-go/actor/actor.proto
ADD https://raw.githubusercontent.com/asynkron/protoactor-go/dev/remote/remote.proto  /usr/include/github.com/asynkron/protoactor-go/remote/remote.proto

# install third-party protos (compatibility)
ADD https://raw.githubusercontent.com/asynkron/protoactor-go/dev/actor/actor.proto    /usr/include/github.com/AsynkronIT/protoactor-go/actor/actor.proto
ADD https://raw.githubusercontent.com/asynkron/protoactor-go/dev/actor/actor.proto    /usr/include/github.com/AsynkronIT/protoactor-go/actor/protos.proto
ADD https://raw.githubusercontent.com/asynkron/protoactor-go/dev/remote/remote.proto  /usr/include/github.com/AsunkronIT/protoactor-go/remote/remote.proto
ADD https://raw.githubusercontent.com/gogo/protobuf/v1.3.2/gogoproto/gogo.proto       /usr/include/github.com/gogo/protobuf/gogoproto/gogo.proto

ENTRYPOINT ["/usr/bin/protoc", "-I=/usr/include"] 
