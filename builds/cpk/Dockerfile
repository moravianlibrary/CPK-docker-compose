FROM localhost/apache-shibboleth

ARG PARAM_VUFIND_SRC=/var/www/cpk
ARG PARAM_VUFIND_PORT=443

# Convert secrets to ENV
ADD https://gist.githubusercontent.com/bvis/b78c1e0841cfd2437f03e20c1ee059fe/raw/53d3c040ed5ee5acdb0ad7c2dbdbac29b77f1ecd/env_secrets_expand.sh /usr/local/bin/secrets-to-env
RUN chmod +x /usr/local/bin/secrets-to-env

COPY ./cpk-foreground /usr/local/bin/
WORKDIR /var/www/cpk

EXPOSE 80
EXPOSE ${PARAM_VUFIND_PORT}

# What was specified as argument on build time, pass as ENV ..
ENV PARAM_VUFIND_SRC=${PARAM_VUFIND_SRC}
ENV PARAM_VUFIND_PORT=${PARAM_VUFIND_PORT}

CMD ["cpk-foreground"]
