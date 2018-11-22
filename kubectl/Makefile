image = sighup/kubectl
tag = v1.11.1

build:
	docker build -t $(image):$(tag) .
	docker build -t $(image):latest .

push:
	docker push $(image):$(tag)
	docker push $(image):latest