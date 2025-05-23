.PHONY: reset-database rspec-run

migrate:
	docker compose run --rm web bundle exec rails db:migrate

reset-database:
	docker compose run --rm web bundle exec rails db:drop db:create db:migrate

rspec:
	docker compose run --rm -e RAILS_ENV=test web bundle exec rspec $(file)
