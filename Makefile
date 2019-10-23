
build:
	docker build -t intersystemsdc/irisdemo-base-mavenc:version-latest .

clean:
	-docker rmi intersystemsdc/irisdemo-base-mavenc:version-latest

push:
	-docker push intersystemsdc/irisdemo-base-mavenc:version-latest

run:
	docker run --rm -it -v ${PWD}/projects/:/usr/projects --name mavenc intersystemsdc/irisdemo-base-mavenc:version-latest