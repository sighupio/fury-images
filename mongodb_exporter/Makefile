image = sighup/mongodb_exporter
tag = v0.6.2

build:
	docker build -t $(image):$(tag) .
	docker build -t $(image):latest .

push:
	docker push $(image):$(tag)
	docker push $(image):latest
