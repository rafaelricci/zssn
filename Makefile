.PHONY: build setup up down db-reset test

build:
	docker compose build

setup:
	docker compose run --rm web rails db:create db:migrate

up:
	docker compose up

down:
	docker compose down

db-reset:
	docker compose run --rm web rails db:drop db:create db:migrate

test:
	docker compose run --rm -e RAILS_ENV=test web bundle exec rspec
