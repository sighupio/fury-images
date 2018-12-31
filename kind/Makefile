image = sighup/kind
tag = v1.12.3-bats

build:
	docker build -t $(image):$(tag) .
	docker build -t $(image):latest .

push:
	docker push $(image):$(tag)
	docker push $(image):latest
