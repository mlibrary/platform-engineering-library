ARG RUBY_VERSION=3.2
FROM ruby:${RUBY_VERSION}

ARG BUNDLER_VERSION=2.4.5 
ARG UNAME=app
ARG UID=1000
ARG GID=1000

RUN gem install bundler:${BUNDLER_VERSION}

RUN groupadd -g ${GID} -o ${UNAME}
RUN useradd -m -d /app -u ${UID} -g ${GID} -o -s /bin/bash ${UNAME}
RUN mkdir -p /gems && chown ${UID}:${GID} /gems

USER $UNAME

ENV BUNDLE_PATH /gems

WORKDIR /app
