default: prepare clean

prepare:
	docker-compose pull && docker-compose build

clean:
	docker-compose kill && docker-compose rm -f
