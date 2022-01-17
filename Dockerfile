FROM ruby:2.6.8

MAINTAINER dxw <rails@dxw.com>

RUN apt-get update && apt-get install -qq -y build-essential libpq-dev nodejs locales --fix-missing --no-install-recommends
RUN echo "en_GB.UTF-8 UTF-8" >> /etc/locale.gen && locale-gen en_GB.UTF-8 UTF-8 && update-locale en_GB.UTF-8 UTF-8
ENV LANGUAGE=en_GB.UTF-8 LC_ALL=en_GB.UTF-8

RUN YARN_VERSION=1.17.3 \
  set -ex \
  && curl -fSLO --compressed "https://yarnpkg.com/downloads/$YARN_VERSION/yarn-v$YARN_VERSION.tar.gz" \
  && mkdir -p /opt/yarn \
  && tar -xzf yarn-v$YARN_VERSION.tar.gz -C /opt/yarn --strip-components=1 \
  && ln -s /opt/yarn/bin/yarn /usr/local/bin/yarn \
  && ln -s /opt/yarn/bin/yarn /usr/local/bin/yarnpkg \
  && rm yarn-v$YARN_VERSION.tar.gz

COPY requirements.txt $INSTALL_PATH/requirements.txt
# This should be kept in sync with the version specified in runtime.txt
ENV PYTHON_VERSION 3.7.4
RUN wget https://www.python.org/ftp/python/${PYTHON_VERSION}/Python-${PYTHON_VERSION}.tgz \
    && tar -xf Python-${PYTHON_VERSION}.tgz \
    && cd Python-${PYTHON_VERSION} \
    && ./configure \
    && make \
    && make install \
    && cd .. \
    && rm Python-${PYTHON_VERSION}.tgz \
    && rm -r Python-${PYTHON_VERSION} \
    && pip3 install --quiet -r $INSTALL_PATH/requirements.txt

RUN ln -s /usr/bin/nodejs /usr/local/bin/node

ENV INSTALL_PATH /srv/dss-api
RUN mkdir -p $INSTALL_PATH

WORKDIR $INSTALL_PATH

# set rails environment
ARG RAILS_ENV
ENV RAILS_ENV=${RAILS_ENV:-production}
ENV RACK_ENV=${RAILS_ENV:-production}

COPY Gemfile $INSTALL_PATH/Gemfile
COPY Gemfile.lock $INSTALL_PATH/Gemfile.lock
COPY package.json yarn.lock $INSTALL_PATH/

RUN yarn
RUN gem update --system 3.0.0
RUN gem install bundler

# bundle ruby gems based on the current environment, default to production
RUN echo $RAILS_ENV
RUN \
  if [ "$RAILS_ENV" = "production" ]; then \
    bundle install --without development test --retry 10; \
  else \
    bundle install --retry 10; \
  fi

COPY . $INSTALL_PATH

RUN bundle exec rake DATABASE_URL=postgresql:does_not_exist SECRET_KEY_BASE=dummy --quiet assets:precompile

COPY ./docker-entrypoint.sh /
RUN chmod +x /docker-entrypoint.sh
EXPOSE 3000

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["rails", "server"]
