FROM localhost/cpk-base

ARG PARAM_VUFIND_BRANCH=
ARG PARAM_VUFIND_COMMIT_HASH=
ARG PARAM_VUFIND_SRC=

COPY ./cpk-clone.sh /usr/local/bin/cpk-clone.sh
COPY ./config.local.template.ini /tmp/
COPY ./EDS.local.template.ini /tmp/
COPY ./bootstrap-source.sh /onstart/004-source.sh
COPY ./cron/expire-users /etc/cron.daily/expire-users
RUN /usr/local/bin/cpk-clone.sh "${PARAM_VUFIND_BRANCH}" "${PARAM_VUFIND_COMMIT_HASH}"

ENV PARAM_VUFIND_HOST=${PARAM_VUFIND_HOST}
ENV PARAM_VUFIND_SSL_PORT=${PARAM_VUFIND_SSL_PORT}
ENV PARAM_VUFIND_RUN_ENV=${PARAM_VUFIND_RUN_ENV}
