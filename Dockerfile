FROM ruby:2.5.1

RUN apt-get update
RUN apt-get install -y build-essential libpq-dev mysql-client && rm -rf /var/lib/apt/lists/*

RUN gem install bundler

RUN mkdir /app
WORKDIR /app
ADD Gemfile /app/Gemfile
ADD Gemfile.lock /app/Gemfile.lock

ARG rails_env
RUN echo rails_env: ${rails_env}

RUN \
  echo 'gem: --no-document' >> ~/.gemrc && \
  cp ~/.gemrc /etc/gemrc && \
  chmod uog+r /etc/gemrc && \
  bundle config --global build.nokogiri --use-system-libraries && \
  bundle config --global jobs 4 && \
  bundle install --with ${rails_env} && \
  rm -rf ~/.gem

ADD . /app

CMD bundle exec rake assets:precompile RAILS_ENV=${RAILS_ENV}

EXPOSE 3000

RUN useradd -r bucky
USER bucky