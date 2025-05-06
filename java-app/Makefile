.PHONY: start clean start-local clean-local

start:
	docker compose up --build

clean:
	docker compose down

start-local:
	docker compose -f docker-compose-local.yml up --build

clean-local:
	docker compose -f docker-compose-local.yml down 