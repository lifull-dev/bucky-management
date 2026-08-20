FROM ruby:3.0.7

RUN apt-get update && \
    apt-get install -y \
      build-essential \
      libpq-dev \
      default-mysql-client \
      && rm -rf /var/lib/apt/lists/*

RUN gem install bundler -v 2.2.33

RUN mkdir /app
WORKDIR /app
ADD . /app

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

# Asset precompilation (skip webpacker as it's not used in this app)
RUN WEBPACKER_PRECOMPILE=false bundle exec rake assets:precompile RAILS_ENV=${RAILS_ENV}

# Copy assets to assets-image for volume sync on startup
# (Volume mounts override /app/public/assets, so we keep a copy)
RUN cp -r /app/public/assets /app/public/assets-image

COPY docker-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

EXPOSE 3000
ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["bundle", "exec", "puma", "-C", "config/puma.rb", "config.ru"]
