FROM buildpack-deps:jessie

# ----------------------------------------------------------------------------
# ruby 2.2 from https://github.com/docker-library/ruby/blob/master/2.2/Dockerfile
# ----------------------------------------------------------------------------

ENV RUBY_MAJOR 2.2
ENV RUBY_VERSION 2.2.2
ENV RUBY_DOWNLOAD_SHA256 5ffc0f317e429e6b29d4a98ac521c3ce65481bfd22a8cf845fa02a7b113d9b44

# some of ruby's build scripts are written in ruby
# we purge this later to make sure our final image uses what we just built
# Froehlich und Frei: removed "rm -rf /var/lib/apt/lists/*"
RUN apt-get update \
    && apt-get install -y bison libgdbm-dev ruby \
    && mkdir -p /usr/src/ruby \
    && curl -fSL -o ruby.tar.gz "http://cache.ruby-lang.org/pub/ruby/$RUBY_MAJOR/ruby-$RUBY_VERSION.tar.gz" \
    && echo "$RUBY_DOWNLOAD_SHA256 *ruby.tar.gz" | sha256sum -c - \
    && tar -xzf ruby.tar.gz -C /usr/src/ruby --strip-components=1 \
    && rm ruby.tar.gz \
    && cd /usr/src/ruby \
    && autoconf \
    && ./configure --disable-install-doc \
    && make -j"$(nproc)" \
    && make install \
    && apt-get purge -y --auto-remove bison libgdbm-dev ruby \
    && rm -r /usr/src/ruby

# skip installing gem documentation
RUN echo 'gem: --no-rdoc --no-ri' >> "$HOME/.gemrc"

# install things globally, for great justice
ENV GEM_HOME /usr/local/bundle
ENV PATH $GEM_HOME/bin:$PATH

ENV BUNDLER_VERSION 1.10.6

RUN gem install bundler --version "$BUNDLER_VERSION" \
    && bundle config --global path "$GEM_HOME" \
    && bundle config --global bin "$GEM_HOME/bin"

# don't create ".bundle" in all our apps
ENV BUNDLE_APP_CONFIG $GEM_HOME


# ----------------------------------------------------------------------------
# node 0.12 from https://github.com/joyent/docker-node/blob/master/0.12/Dockerfile
# ----------------------------------------------------------------------------

# verify gpg and sha256: http://nodejs.org/dist/v0.10.30/SHASUMS256.txt.asc
# gpg: aka "Timothy J Fontaine (Work) <tj.fontaine@joyent.com>"
# gpg: aka "Julien Gilli <jgilli@fastmail.fm>"
RUN gpg --keyserver pool.sks-keyservers.net --recv-keys 7937DFD2AB06298B2293C3187D33FF9D0246406D 114F43EE0176B71C7BC219DD50A3051F888C628D

ENV NODE_VERSION 0.12.7
ENV NPM_VERSION 2.13.2

RUN curl -SLO "https://nodejs.org/dist/v$NODE_VERSION/node-v$NODE_VERSION-linux-x64.tar.gz" \
    && curl -SLO "https://nodejs.org/dist/v$NODE_VERSION/SHASUMS256.txt.asc" \
    && gpg --verify SHASUMS256.txt.asc \
    && grep " node-v$NODE_VERSION-linux-x64.tar.gz\$" SHASUMS256.txt.asc | sha256sum -c - \
    && tar -xzf "node-v$NODE_VERSION-linux-x64.tar.gz" -C /usr/local --strip-components=1 \
    && rm "node-v$NODE_VERSION-linux-x64.tar.gz" SHASUMS256.txt.asc \
    && npm install -g npm@"$NPM_VERSION" \
    && npm cache clear


# ----------------------------------------------------------------------------
# Fröhlich und Frei Land
# ----------------------------------------------------------------------------

# install extra packages
RUN apt-get update \
  && apt-get install -y \
    python-pygments \
    make \
    openjdk-7-jre \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

# install ruby gems
RUN gem install \
  jekyll \
  s3_website

# trigger s3_website push to download s3_website.jar
RUN s3_website push --dry-run || true

# Install Node Packages
RUN npm install -g bower gulp

CMD ["bash"]

