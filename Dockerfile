FROM ruby:3.1.4

RUN apt-get update && \
    apt-get install -y \
      build-essential \
      libpq-dev \
      default-mysql-client \
      && rm -rf /var/lib/apt/lists/*

RUN gem install bundler -v 2.5.17

RUN mkdir /app
WORKDIR /app
ADD . /app

ARG RAILS_ENV
RUN echo RAILS_ENV: ${RAILS_ENV}

RUN echo 'gem: --no-document' >> ~/.gemrc
RUN cp ~/.gemrc /etc/gemrc
RUN chmod uog+r /etc/gemrc
RUN bundle config --global build.nokogiri --use-system-libraries
RUN bundle config --global jobs 4
RUN bundle config set --local with "${RAILS_ENV}"
RUN gem cleanup

RUN bundle install --verbose
RUN rm -rf ~/.gem

CMD bundle exec rake assets:precompile RAILS_ENV=${RAILS_ENV}

EXPOSE 3000