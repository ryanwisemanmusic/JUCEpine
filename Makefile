build:
	mkdir -p output
	docker buildx build \
		--platform linux/amd64 \
		--no-cache \
		-t jucepine:latest . 2>&1 | tee build.log
	@echo "Build complete."


run:
	docker run -it jucepine 2>&1 | tee run.log

run-via-bash:
	docker run -it jucepine /bin/sh 2>&1 | tee run.log

clean:
	docker rmi jucepine 2>/dev/null || true
	docker system prune -f
	rm -f build.log run.log
	rm -rf output

.PHONY: build run run-via-bash clean
