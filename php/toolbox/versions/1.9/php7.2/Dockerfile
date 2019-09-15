# PHP tools v1.9
#
# docker run --rm -t supinf/php-tools:1.9-php7.2
# docker run --rm -t -v $(pwd):/work -v /tmp:/tmp supinf/php-tools:1.9-php7.2 phpunit src
# docker run --rm -t -v $(pwd):/work -v /tmp:/tmp supinf/php-tools:1.9-php7.2 pdepend src
# docker run --rm -t -v $(pwd):/work -v /tmp:/tmp supinf/php-tools:1.9-php7.2 phpcf src --exclude system
# docker run --rm -t -v $(pwd):/work -v /tmp:/tmp supinf/php-tools:1.9-php7.2 phplint src
# docker run --rm -t -v $(pwd):/work -v /tmp:/tmp supinf/php-tools:1.9-php7.2 psecio-parse src
# docker run --rm -t -v $(pwd):/work -v /tmp:/tmp supinf/php-tools:1.9-php7.2 phpstan analyse src

FROM php:7.2.22-cli-alpine3.10

COPY --from=composer:1.9.0 /usr/bin/composer /usr/bin/composer

ENV TOOLBOX_VERSION="1.9.2"
ENV TOOLBOX_TARGET_DIR="/tools"
ENV COMPOSER_HOME="${TOOLBOX_TARGET_DIR}/.composer"
ENV PATH="$PATH:$TOOLBOX_TARGET_DIR:$TOOLBOX_TARGET_DIR/.composer/vendor/bin:$TOOLBOX_TARGET_DIR/QualityAnalyzer/bin:$TOOLBOX_TARGET_DIR/DesignPatternDetector/bin:$TOOLBOX_TARGET_DIR/EasyCodingStandard/bin"

RUN apk add --no-cache tini git graphviz make unzip zlib-dev libzip-dev \
    && apk add --no-cache --virtual build-deps autoconf file g++ gcc libc-dev pkgconf re2c \
    && git clone https://github.com/nikic/php-ast.git \
    && cd php-ast \
    && phpize \
    && ./configure && make && make install \
    && cd .. && rm -rf php-ast \
    && docker-php-ext-enable ast \
    && docker-php-ext-install zip pcntl \
    && echo "date.timezone=UTC" >> "$PHP_INI_DIR/php.ini" \
    && echo "memory_limit=-1" >> "$PHP_INI_DIR/php.ini" \
    && echo "phar.readonly=0" >> "$PHP_INI_DIR/php.ini" \
    && mkdir -p "${TOOLBOX_TARGET_DIR}" \
    && curl -Ls "https://github.com/jakzal/toolbox/releases/download/v${TOOLBOX_VERSION}/toolbox.phar" \
         -o "${TOOLBOX_TARGET_DIR}/toolbox" \
    && chmod +x "${TOOLBOX_TARGET_DIR}/toolbox" \
    && php "${TOOLBOX_TARGET_DIR}/toolbox" install --exclude-tag "exclude-php:7.2" \
    && rm -rf "${COMPOSER_HOME}/cache" \
    && apk del --purge -r build-deps

WORKDIR /work
ENTRYPOINT ["/sbin/tini", "--"]
CMD ["toolbox", "list-tools"]
