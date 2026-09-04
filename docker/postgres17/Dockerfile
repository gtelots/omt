FROM oraclelinux:9

ARG PG_MAJOR=17
ARG PGSQL_GZIP_TAG=v1.0.0
ARG UTF8PROC_TAG=v2.5.0
ARG MAPNIK_GERMAN_L10N_TAG=v2.5.9.3
ARG KAKASI_VERSION=2.3.6

ENV PGDATA=/var/lib/postgresql/data \
    PGPORT=5432 \
    POSTGRES_DB=openmaptiles \
    POSTGRES_USER=openmaptiles \
    POSTGRES_PASSWORD=openmaptiles \
    PATH=/usr/pgsql-17/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

RUN set -eux; \
    mkdir -p /etc/alternatives; \
    dnf -y install dnf-plugins-core oracle-epel-release-el9; \
    dnf -qy module disable postgresql; \
    dnf -y install https://download.postgresql.org/pub/repos/yum/reporpms/EL-9-x86_64/pgdg-redhat-repo-latest.noarch.rpm; \
    dnf config-manager --set-enabled ol9_codeready_builder || true; \
    dnf config-manager --set-enabled ol9_developer_EPEL || true; \
    dnf -y makecache; \
    dnf -y install \
      ca-certificates \
      clang \
      curl \
      file \
      findutils \
      gcc \
      gcc-c++ \
      gdal-devel \
      git \
      glibc-gconv-extra \
      gzip \
      libicu-devel \
      llvm \
      make \
      pandoc \
      pgrouting_17 \
      postgis35_17 \
      postgis35_17-devel \
      postgis35_17-utils \
      postgresql17 \
      postgresql17-contrib \
      postgresql17-devel \
      postgresql17-server \
      tar \
      which \
      xz \
      zlib-devel; \
    dnf clean all; \
    rm -rf /var/cache/dnf

RUN set -eux; \
    dnf -y install annobin redhat-rpm-config; \
    dnf clean all; \
    rm -rf /var/cache/dnf

RUN set -eux; \
    cd /opt; \
    curl -fsSLo kakasi.tar.xz "https://deb.debian.org/debian/pool/main/k/kakasi/kakasi_${KAKASI_VERSION}.orig.tar.xz"; \
    mkdir kakasi; \
    tar -xf kakasi.tar.xz -C kakasi --strip-components=1; \
    cd kakasi; \
    CFLAGS="-O2 -Wno-implicit-int -Wno-implicit-function-declaration" ./configure --prefix=/usr/local; \
    make; \
    make install; \
    echo /usr/local/lib > /etc/ld.so.conf.d/usr-local-lib.conf; \
    ldconfig; \
    rm -rf /opt/kakasi /opt/kakasi.tar.xz

RUN set -eux; \
    cd /opt; \
    git clone --quiet --depth 1 -b "${PGSQL_GZIP_TAG}" https://github.com/pramsey/pgsql-gzip.git; \
    cd pgsql-gzip; \
    make PG_CONFIG=/usr/pgsql-17/bin/pg_config with_llvm=no; \
    make PG_CONFIG=/usr/pgsql-17/bin/pg_config with_llvm=no install; \
    rm -rf /opt/pgsql-gzip

RUN set -eux; \
    cd /opt; \
    git clone --quiet --depth 1 -b "${UTF8PROC_TAG}" https://github.com/JuliaLang/utf8proc.git; \
    cd utf8proc; \
    make; \
    make install; \
    ldconfig; \
    rm -rf /opt/utf8proc

RUN set -eux; \
    cd /opt; \
    git clone --quiet --depth 1 -b "${MAPNIK_GERMAN_L10N_TAG}" https://github.com/openmaptiles/mapnik-german-l10n.git; \
    cd mapnik-german-l10n; \
    for src in kanjitranscript/kanjitranscript.c icutranslit/osml10n_translit.cpp; do \
      sed -i \
        -e '/#include <postgres.h>/a #include <varatt.h>' \
        -e 's/VARSIZE(t) - VARHDRSZ/VARSIZE_ANY_EXHDR(t)/g' \
        -e 's/VARDATA(t)/VARDATA_ANY(t)/g' \
        -e 's/VARDATA(new_text)/VARDATA_ANY(new_text)/g' \
        -e 's/SET_VARSIZE(/SET_VARSIZE_4B(/g' \
        "$src"; \
    done; \
    make with_llvm=no; \
    make with_llvm=no install; \
    rm -rf /opt/mapnik-german-l10n

COPY docker/postgres17/docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
COPY docker/postgres17/smoke-test.sql /usr/local/share/openmaptiles/smoke-test.sql
COPY docker/postgres17/omt-smoke-test /usr/local/bin/omt-smoke-test

RUN set -eux; \
    chmod +x /usr/local/bin/docker-entrypoint.sh /usr/local/bin/omt-smoke-test; \
    mkdir -p /var/lib/postgresql; \
    chown -R postgres:postgres /var/lib/postgresql

EXPOSE 5432

ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["postgres"]
