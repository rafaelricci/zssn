# syntax=docker/dockerfile:1

FROM ruby:3.4.4-slim

WORKDIR /app

RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y \
    build-essential \
    libpq-dev \
    nodejs \
    curl \
    git \
    postgresql-client \
    libvips \
    libyaml-dev && \
    rm -rf /var/lib/apt/lists /var/cache/apt/archives

COPY Gemfile Gemfile.lock ./

RUN gem install bundler && bundle install

COPY . .

EXPOSE 3000

CMD ["bash", "-c", "rm -f tmp/pids/server.pid && bundle exec rails s -b 0.0.0.0"]
