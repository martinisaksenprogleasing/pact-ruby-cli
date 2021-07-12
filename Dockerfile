FROM mcr.microsoft.com/dotnet/runtime-deps:3.1.16-focal

LABEL maintainer="Martin Isaksen <norway.martin@gmail.com>"

ENV NOKOGIRI_USE_SYSTEM_LIBRARIES=1
ENV BUNDLE_SILENCE_ROOT_WARNING=1

ADD docker/gemrc /root/.gemrc
ADD docker/pact /usr/local/bin/pact

# Update from rubygems 2.7.6 to 3.0.3 for security reasons
# Verify with gem -v
# TODO: Remove this when it is no longer needed

RUN apt-get update \
  && apt-get -y install build-essential \
  && apt-get -qq -y install ruby \
			 ruby-dev \
             ca-certificates \
             less \
             git \
  \
  && gem update --system \
  && gem install bundler \
  && bundler -v \
  && bundle config build.nokogiri --use-system-libraries \
  && bundle config git.allow_insecure true \
  && gem install json -v "~>2.3" \
  && gem cleanup \
  && rm -rf /usr/lib/ruby/gems/*/cache/* \
            /tmp/* \
            /var/tmp/* 

ENV DOCKER true
ENV BUNDLE_GEMFILE=./Gemfile

ADD pact-cli.gemspec .
ADD Gemfile .
ADD Gemfile.lock .
ADD lib/pact/cli/version.rb ./lib/pact/cli/version.rb
RUN bundle config set without 'test development' \
      && bundle install \
      && find /usr/lib/ruby/gems/*/gems -name Gemfile.lock -maxdepth 2 -delete
ADD docker/entrypoint.sh ./entrypoint.sh
ADD bin ./bin
ADD lib ./lib
ADD example/pacts ./example/pacts
