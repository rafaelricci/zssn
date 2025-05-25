FROM ruby:3.4.4-slim

RUN apt-get update -qq && apt-get install -y \
  build-essential \
  libpq-dev \
  nodejs \
  curl \
  git \
  libvips \
  libyaml-dev \
  && apt-get clean

WORKDIR /app

COPY Gemfile Gemfile.lock ./
RUN bundle install

COPY . .

EXPOSE 3000
CMD ["bash", "-c", "rm -f tmp/pids/server.pid && bundle exec rails s -b 0.0.0.0"]
