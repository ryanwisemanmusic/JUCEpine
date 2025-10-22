build:
	docker build -t jucepine . 2>&1 | tee build.log

run:
	docker run -it jucepine 2>&1 | tee run.log

clean:
	docker rmi jucepine || true
	docker system prune -f
	rm -f build.log run.log

.PHONY: build run clean