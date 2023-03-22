FROM golang:1.20.2-bullseye AS plugin

ARG protoc_version=3.19.6
ARG protoc_url=https://github.com/protocolbuffers/protobuf/releases/download/v${protoc_version}/protoc-${protoc_version}-linux-x86_64.zip
ARG goproxy=direct
ARG repo_name=codeplaytech/protoactor-go

ENV GOPROXY=${goproxy}
ENV GOPATH=/gopath/

RUN go install github.com/gogo/protobuf/protoc-gen-gogoslick@v1.3.2 \
    && go install google.golang.org/protobuf/cmd/protoc-gen-go@latest

# install go code generator(compatibility).
# https://developers.google.com/protocol-buffers/docs/reference/go/faq
RUN git clone https://github.com/codeplaytech/protoactor-go -b master --depth=1 \
    && cd ./protoactor-go/protobuf/protoc-gen-gograinv2 \
    && go install .

RUN pwd


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



# third-party protos
COPY --from=plugin /go/protoactor-go/actor/protos.proto /usr/include/github.com/asynkron/protoactor-go/actor/actor.proto
COPY --from=plugin /go/protoactor-go/remote/protos.proto /usr/include/github.com/asynkron/protoactor-go/remote/remote.proto


COPY --from=plugin /go/protoactor-go/actor/protos.proto /usr/include/github.com/AsynkronIT/protoactor-go/actor/protos.proto

COPY --from=plugin /go/protoactor-go/remote/protos.proto /usr/include/github.com/AsynkronIT/protoactor-go/remote/protos.proto

# third-party protos (compatibility)
ADD https://raw.githubusercontent.com/gogo/protobuf/v1.3.2/gogoproto/gogo.proto       /usr/include/github.com/gogo/protobuf/gogoproto/gogo.proto

ENTRYPOINT ["/usr/bin/protoc", "-I=/usr/include"] 
