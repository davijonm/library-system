FROM ruby:3.4.2

RUN apt-get update && apt-get install -y postgresql-client

WORKDIR /rails

COPY library-api/Gemfile library-api/Gemfile.lock ./
RUN gem install bundler
RUN bundle install

COPY library-api/ .

EXPOSE 3000

CMD ["rails", "server", "-b", "0.0.0.0"]