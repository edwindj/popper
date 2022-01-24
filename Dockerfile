# Install chromium in Docker
# https://github.com/GoogleChrome/puppeteer/blob/master/docs/troubleshooting.md#running-on-alpine
#
FROM node:alpine

ARG ROOT=/srv

# Tell Puppeteer to skip installing Chrome. We'll be using the installed package.
#ENV CHROME_BIN="/usr/bin/chromium-browser"
ENV PUPPETEER_SKIP_CHROMIUM_DOWNLOAD true


# Installs latest Chromium package.
RUN echo "http://dl-cdn.alpinelinux.org/alpine/edge/main" > /etc/apk/repositories \
    && echo "http://dl-cdn.alpinelinux.org/alpine/edge/community" >> /etc/apk/repositories \
    && echo "http://dl-cdn.alpinelinux.org/alpine/edge/testing" >> /etc/apk/repositories \
    && echo "http://dl-cdn.alpinelinux.org/alpine/v3.12/main" >> /etc/apk/repositories \
    && apk upgrade -U -a \
    && apk add \
    libstdc++ \
    chromium \
    harfbuzz \
    nss \
    freetype \
    ttf-freefont \
    font-noto-emoji \
    wqy-zenhei \
    bash \
    && rm -rf /var/cache/* \
    && mkdir /var/cache/apk

ENV CHROME_BIN=/usr/bin/chromium-browser \
    CHROME_PATH=/usr/lib/chromium/

# Expose port 3000
EXPOSE 3000

# Install npm libs
WORKDIR ${ROOT}
COPY package.json .
RUN npm install

# Define entrypoint
COPY deployment/entrypoint.sh /usr/local/bin/
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]

# Add Chrome as a user
RUN adduser -D chrome \
    && chown -R chrome:chrome ${ROOT}

# Run Chrome as non-privileged
USER chrome

# Default command
CMD ["server"]

COPY src/ ${ROOT}/src/
