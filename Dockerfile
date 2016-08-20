FROM marcbachmann/libvips:latest
MAINTAINER Tomas Celizna <tomas.celizna@gmail.com>

RUN mkdir /app
WORKDIR /app

RUN mkdir lib
RUN mkdir lib/dragonfly_fonts

ADD Gemfile Gemfile
ADD dragonfly_libvips.gemspec dragonfly_libvips.gemspec
ADD lib/dragonfly_libvips/version.rb lib/dragonfly_libvips/version.rb

RUN bundle install
ADD . /app
