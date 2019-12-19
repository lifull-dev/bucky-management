FROM ruby:2.5.1-alpine
RUN apk update && \
    apk add --no-cache \
      alpine-sdk \
      bash \
      build-base \
      libstdc++ \
      libxml2-dev \
      libxslt-dev \
      linux-headers \
      mysql-client \
      mysql-dev \
      nodejs \
      ruby-dev \
      ruby-json \
      tzdata \
      yaml \
      yaml-dev \
      zlib-dev

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
