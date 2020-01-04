FROM ruby:2.6-rc
LABEL maintainer="dlleal@uc.cl"

RUN apt-get update \
    && apt-get install -y postgresql-client \
    && apt-get install -y nodejs \
    # add support to unicode chars from keyboard: ç,ã,ô:
    && apt-get install -y locales \
    && echo "en_US.UTF-8 UTF-8" > /etc/locale.gen && /usr/sbin/locale-gen \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir /myapp
WORKDIR /myapp
COPY Gemfile Gemfile.lock /myapp/
RUN bundle install

COPY . /myapp

# Fix C.UTF-8 bugs
ENV LANG en_US.UTF-8

# Fix Heroku sass bug
ENV BUNDLE_BUILD__SASSC=--disable-march-tune-native

# Add a script to be executed every time the container starts.
COPY entrypoint.sh /usr/bin/
RUN chmod +x /usr/bin/entrypoint.sh
ENTRYPOINT ["entrypoint.sh"]
EXPOSE 3000

# Run as non-root user
RUN useradd -m myuser
USER myuser

# Start the main process.
CMD ["puma", "-C", "config/puma.rb"]
