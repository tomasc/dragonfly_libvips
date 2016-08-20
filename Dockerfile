FROM marcbachmann/libvips:latest
MAINTAINER Tomas Celizna <tomas.celizna@gmail.com>

RUN git clone https://github.com/sstephenson/rbenv.git /usr/local/rbenv

RUN mkdir /usr/local/rbenv/plugins
RUN git clone https://github.com/sstephenson/ruby-build.git /usr/local/rbenv/plugins/ruby-build
RUN cd /usr/local/rbenv/plugins/ruby-build && ./install.sh

ENV RBENV_ROOT /usr/local/rbenv
ENV PATH /usr/local/rbenv/shims:/usr/local/rbenv/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

RUN rbenv install 2.2.5
ENV RBENV_VERSION 2.2.5

RUN gem install bundler
RUN rbenv rehash

RUN mkdir /app
WORKDIR /app

RUN mkdir lib
RUN mkdir lib/dragonfly_fonts

ADD Gemfile Gemfile
ADD dragonfly_libvips.gemspec dragonfly_libvips.gemspec
ADD lib/dragonfly_libvips/version.rb lib/dragonfly_libvips/version.rb

RUN bundle install
ADD . /app
