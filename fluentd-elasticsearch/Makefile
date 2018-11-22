image = sighup/fluentd-elasticsearch:1.2.8

build:
	docker build -t $(image) .

push:
	docker push $(image)

all: build push