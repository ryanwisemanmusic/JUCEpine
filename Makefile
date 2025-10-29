build:
	mkdir -p output
	docker-compose build --no-cache juce-builder 2>&1 | tee build.log
	@echo "Build complete."

run:
	docker-compose run --rm juce-builder 2>&1 | tee run.log

run-via-bash:
	docker-compose run --rm juce-builder /bin/sh 2>&1 | tee run.log

clean:
	docker rmi jucepine 2>/dev/null || true
	docker system prune -f
	rm -f build.log run.log
	rm -rf output

.PHONY: build run run-via-bash clean
