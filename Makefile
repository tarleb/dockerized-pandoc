NAME ?= tarleb/buster-slim-pandoc

build:
	docker build \
	    --tag $(NAME):latest \
	    debian

clean:
	docker rmi $(NAME):latest
