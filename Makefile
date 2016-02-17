build:
	@echo "Building ekg-swift"
	@swift build

debug: build
	lldb .build/debug/ekg-swift

run: build
	.build/debug/ekg-swift --timeout 10000

redis-start:
	@redis-server TestRedis/redis.conf

redis-stop:
	@if [ -e "TestRedis/redis.pid" ]; then kill `cat TestRedis/redis.pid`; fi;

redis:
	@if [ ! -e "TestRedis/redis.pid" ]; then redis-server TestRedis/redis.conf; fi;

clean: redis-stop
	rm -fr .build Packages TestRedis/dump.rdb