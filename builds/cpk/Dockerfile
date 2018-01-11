FROM localhost/apache-shibboleth

ARG PARAM_VUFIND_SRC=/var/www/cpk
ARG PARAM_VUFIND_PORT=443
ARG PARAM_VUFIND_BRANCH=
ARG PARAM_VUFIND_COMMIT_HASH=

# Convert secrets to ENV
ADD https://gist.githubusercontent.com/bvis/b78c1e0841cfd2437f03e20c1ee059fe/raw/53d3c040ed5ee5acdb0ad7c2dbdbac29b77f1ecd/env_secrets_expand.sh /usr/local/bin/secrets-to-env
RUN chmod +x /usr/local/bin/secrets-to-env

COPY ./cpk-clone.sh /usr/local/bin/cpk-clone.sh
COPY ./config.local.template.ini /tmp/
COPY ./bootstrap-cpk.sh /onstart/003-cpk.sh
COPY ./cpk-foreground /usr/local/bin/
RUN /usr/local/bin/cpk-clone.sh "${PARAM_VUFIND_BRANCH}" "${PARAM_VUFIND_COMMIT_HASH}"

WORKDIR /var/www/cpk

EXPOSE 80
EXPOSE ${PARAM_VUFIND_PORT}

# What was specified as argument on build time, pass as ENV ..
ENV PARAM_VUFIND_SRC=${PARAM_VUFIND_SRC}
ENV PARAM_VUFIND_PORT=${PARAM_VUFIND_PORT}

ENV PARAM_VUFIND_GOOGLE_API_KEY=${PARAM_VUFIND_GOOGLE_API_KEY}
ENV PARAM_VUFIND_CAPTCHA_SITE_KEY=${PARAM_VUFIND_CAPTCHA_SITE_KEY}
ENV PARAM_VUFIND_CAPTCHA_SECRET_KEY=${PARAM_VUFIND_CAPTCHA_SECRET_KEY}
ENV PARAM_VUFIND_MYSQL_URL=${PARAM_VUFIND_MYSQL_URL}

CMD ["cpk-foreground"]
