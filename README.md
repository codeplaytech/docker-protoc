# Usage
## Bash
```bash
docker run --rm -it ghcr.io/codeplaytech/protoc:v3.19.6-5
```

## Makefile
```makefile
work_dir :=$(CURDIR)
protoc :=sudo docker run -it --rm \
	-v $(work_dir)/:/server \
	-w /server \
	ghcr.io/codeplaytech/protoc:v3.19.6-5

proto_opts:=-I=. --gogoslick_out=Mgoogle/protobuf/any.proto=github.com/gogo/protobuf/types:.
grain_opts:=-I=. --gograinv2_out=.

proto:
	@for f in $(shell find . -iname "*.proto"); do \
		echo compiling $$f;  \
		$(protoc) $(proto_opts) $$f; \
	done


proto-grain:
	@for f in $(shell find . -iname "api.proto"); do \
		echo compiling $$f;  \
		$(protoc) $(proto_opts) $$f; \
		$(protoc) $(grain_opts) $$f; \
	done
	sudo rm -fr github_com/
	sudo rm -fr google/
```
