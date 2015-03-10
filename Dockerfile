FROM ubuntu:14.04

MAINTAINER Luis Elizondo "lelizondo@gmail.com"
ENV DEBIAN_FRONTEND noninteractive

# Ensure UTF-8
RUN locale-gen en_US.UTF-8
ENV LANG       en_US.UTF-8
ENV LC_ALL     en_US.UTF-8

# Update system
RUN apt-get update && apt-get dist-upgrade -y

# Prevent restarts when installing
RUN echo '#!/bin/sh\nexit 101' > /usr/sbin/policy-rc.d && chmod +x /usr/sbin/policy-rc.d

# Basic packages
RUN apt-get -y install make git-core curl zlib1g-dev wget build-essential libssl-dev libreadline-dev libyaml-dev libsqlite3-dev sqlite3 libxml2-dev libxslt1-dev libcurl4-openssl-dev python-software-properties libffi-dev
RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 561F9B9CAC40B2F7
RUN apt-get install -y apt-transport-https ca-certificates
RUN echo "deb https://oss-binaries.phusionpassenger.com/apt/passenger trusty main" >> /etc/apt/sources.list.d/passenger.list
RUN apt-get update
RUN apt-get -y --force-yes install nginx-extras passenger supervisor

# Install ruby
RUN cd /tmp ; wget http://ftp.ruby-lang.org/pub/ruby/2.2/ruby-2.2.1.tar.gz ; tar -xzvf ruby-2.2.1.tar.gz
RUN cd /tmp/ruby-2.2.1/ ; ./configure
RUN cd /tmp/ruby-2.2.1/ ; make ; make install

RUN gem install rails
RUN gem update --system
RUN gem install rubygems-update
RUN update_rubygems

RUN cd /tmp ; rails new webapp ; cd /tmp/webapp ; bundle install

RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Prepare directory
RUN mkdir /var/www
RUN usermod -u 1000 www-data
RUN usermod -a -G users www-data
RUN chown -R www-data:www-data /var/www

EXPOSE 80
EXPOSE 3000

WORKDIR /var/www
CMD ["/usr/bin/supervisord", "-n"]

### Add configuration files
# Supervisor
ADD ./config/supervisor/supervisord-rails.conf /etc/supervisor/conf.d/supervisord-rails.conf
