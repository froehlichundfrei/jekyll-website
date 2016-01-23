DOCKER_IMAGENAME = froehlichundfrei/jekyll-website
DOCKER_CONTAINERNAME = jekyll-website

build:
	docker build -t $(DOCKER_IMAGENAME) .

clean:
	docker rm -f $(DOCKER_CONTAINERNAME) >> /dev/null || true
	docker rmi $(DOCKER_IMAGENAME) || true

run:
	docker rm -f $(DOCKER_CONTAINERNAME) >> /dev/null || true
	docker run -it  --name $(DOCKER_CONTAINERNAME) \
		-h $(DOCKER_CONTAINERNAME) $(DOCKER_IMAGENAME)
