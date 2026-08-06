.PHONY: all install start stop restart clean test

all: start

install:
	./scripts/install.sh

start:
	./scripts/start.sh

stop:
	./scripts/stop.sh

restart:
	./scripts/restart.sh

test:
	lua tests/test.lua

clean:
	rm -f logs/*.log data/backups/*.json data/backups/*.rdb
	find . -name "*.pid" -delete

docker-up:
	docker-compose up -d

docker-down:
	docker-compose down
