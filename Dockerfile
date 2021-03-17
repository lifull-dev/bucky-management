FROM ruby:2.7.2

RUN apt-get update
RUN apt-get install -y build-essential libpq-dev default-mysql-client && rm -rf /var/lib/apt/lists/*

RUN gem update --system
RUN gem install bundler

RUN mkdir /app
WORKDIR /app
ADD Gemfile /app/Gemfile
# ADD Gemfile.lock /app/Gemfile.lock

ARG RAILS_ENV
RUN echo RAILS_ENV: ${RAILS_ENV}

RUN \
  echo 'gem: --no-document' >> ~/.gemrc && \
  cp ~/.gemrc /etc/gemrc && \
  chmod uog+r /etc/gemrc && \
  bundle config --global build.nokogiri --use-system-libraries && \
  bundle config --global jobs 4 && \
  bundle config set --local with "${RAILS_ENV}" && \
  bundle install && \
  rm -rf ~/.gem

ADD . /app

CMD bundle exec rake assets:precompile RAILS_ENV=${RAILS_ENV}

EXPOSE 3000
