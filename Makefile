build:
	docker compose build --parallel response nginx

up:
	docker compose up -d nginx

down:
	docker compose down

test:
	docker compose run --build --rm tests
