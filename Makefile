protoc_version:=3.19.4
protoc_image_tag:=$(protoc_version)-$(shell date +'%Y%m%d')
protoc_url:=https://github.com/protocolbuffers/protobuf/releases/download/v$(protoc_version)/protoc-$(protoc_version)-linux-x86_64.zip
protoc_url_cache:=http://127.0.0.1:9527/protoc-$(protoc_version)-linux-x86_64.zip


build:
	docker build . \
		--network host \
		--build-arg protoc_url=$(protoc_url_cache) \
		--build-arg goproxy=https://goproxy.cn,direct \
		--tag cupen/protoc:$(protoc_image_tag)


push2dockerhub:
	docker push cupen/protoc:$(protoc_image_tag)


serve-cache:
	[ -f protoc-$(protoc_version)-linux-x86_64.zip ] || wget $(protoc_url)
	python -m http.server 9527

