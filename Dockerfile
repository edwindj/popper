FROM zenika/alpine-chrome:89-with-node

USER root

# Expose port 3000
EXPOSE 3000

RUN chown -R chrome:chrome /srv \
 && apk add --no-cache bash

WORKDIR /srv
USER chrome

# Install npm libs
COPY package.json .
RUN npm install

# Define entrypoint
COPY deployment/entrypoint.sh /usr/local/bin/
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]

# Default command
CMD ["server"]

COPY src/ /srv/src/
