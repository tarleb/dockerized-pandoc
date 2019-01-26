NAME ?= tarleb/buster-slim-pandoc

build:
	docker build \
	    --tag $(NAME):latest \
	    .

clean:
	docker rmi $(NAME):latest
