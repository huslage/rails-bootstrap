FROM ubuntu

RUN apt-get update -qq && DEBIAN_FRONTEND=noninteractive apt-get -q -y install build-essential curl git zlib1g-dev libssl-dev libreadline-dev libyaml-dev libxml2-dev libxslt-dev libsqlite3-dev nodejs-legacy nodejs-dev npm

ENV RUBY_VERSION="2.2.3" \
    CONFIGURE_OPTS="--disable-install-doc" \
    RAILS_ENV="production" \
    SECRET_KEY_BASE="$(openssl rand -base64 32)" \
    PATH="/root/.rbenv/bin:/root/.rbenv/shims:$PATH"

RUN git clone https://github.com/sstephenson/rbenv.git ~/.rbenv \
    && git clone https://github.com/sstephenson/ruby-build.git ~/.rbenv/plugins/ruby-build \
    && ~/.rbenv/plugins/ruby-build/install.sh \
    && echo 'eval "$(rbenv init -)"' >> ~/.bashrc \
    && rbenv install $RUBY_VERSION \
    && rbenv global $RUBY_VERSION \
    && echo "gem: --no-ri --no-rdoc" > ~/.gemrc \
    && gem install bundler
RUN mkdir -p /app
WORKDIR /app
COPY Gemfile* /app/
RUN bundle install --without development test --jobs 4
COPY . /app/
RUN bundle exec rake assets:precompile

EXPOSE 3000