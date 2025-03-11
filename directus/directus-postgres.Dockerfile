#ddev-generated

FROM directus/directus:11

ARG uid
ARG gid

USER root
RUN apk --no-cache add shadow
RUN groupmod --gid $gid node
RUN usermod -u $uid -g $gid node

USER node
