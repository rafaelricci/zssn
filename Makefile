# Makefile

.PHONY: reset-database rspec-run

# Comando para resetar o banco de dados de desenvolvimento
reset-database:
	docker compose run --rm web bundle exec rails db:drop db:create db:migrate

# Comando para rodar os testes no ambiente de teste
rspec-run:
	docker compose run --rm -e RAILS_ENV=test web bundle exec rspec
