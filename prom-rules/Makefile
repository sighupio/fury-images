image = sighup/prom-rules
tag = v1.0.0

build:
	docker build -t $(image):$(tag) .
	docker build -t $(image):latest .

push:
	docker push $(image):$(tag)
	docker push $(image):latest
