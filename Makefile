build:
	mkdir -p output keys packages distfiles
	docker-compose build --no-cache juce-builder 2>&1 | tee build.log
	@echo "Build complete."

run:
	docker-compose up juce-builder 2>&1 | tee run.log

run-via-bash:
	docker-compose run --rm juce-builder /bin/bash 2>&1 | tee run.log

clean:
	docker-compose down 2>/dev/null || true
	docker rmi jucepine 2>/dev/null || true
	docker system prune -f
	rm -f build.log run.log
	find packages -name "*.apk" -delete 2>/dev/null || true
	find packages -name "APKINDEX*" -delete 2>/dev/null || true
	rm -rf keys/*.rsa* 2>/dev/null || true
	rm -rf keys/abuild.conf 2>/dev/null || true
	mkdir -p keys packages distfiles

.PHONY: build run run-via-bash clean