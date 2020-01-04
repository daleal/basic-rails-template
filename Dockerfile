FROM ruby:2.6-rc
LABEL maintainer="dlleal@uc.cl"

# Install necessary dependencies
RUN curl https://deb.nodesource.com/setup_12.x | bash \
    && curl https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - \
    && echo "deb https://dl.yarnpkg.com/debian/ stable main" | \
        tee /etc/apt/sources.list.d/yarn.list \
    && apt-get update && apt-get install -y nodejs yarn postgresql-client \
    # add support to unicode chars from keyboard: ç,ã,ô:
    && apt-get install -y locales \
    && echo "en_US.UTF-8 UTF-8" > /etc/locale.gen && /usr/sbin/locale-gen \
    && rm -rf /var/lib/apt/lists/* \
    && mkdir -p /myapp

# Copy Gemfile to image
COPY Gemfile Gemfile.lock /myapp/
WORKDIR /myapp

# Install gems
RUN bundle install

# Run yarn
RUN yarn install

# Copy files to image
COPY . /myapp

# Precompile assets
RUN bundle exec rails assets:precompile

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
