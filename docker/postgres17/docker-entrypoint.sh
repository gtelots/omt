#!/usr/bin/env bash
set -Eeuo pipefail

if [[ "${1:-}" == "postgres" || "${1:-}" == -* ]]; then
  if [[ "${1:-}" == -* ]]; then
    set -- postgres "$@"
  fi

  export PGDATA="${PGDATA:-/var/lib/postgresql/data}"
  export PGPORT="${PGPORT:-5432}"
  export POSTGRES_DB="${POSTGRES_DB:-openmaptiles}"
  export POSTGRES_USER="${POSTGRES_USER:-openmaptiles}"
  export POSTGRES_PASSWORD="${POSTGRES_PASSWORD:-openmaptiles}"

  # During bootstrap the client tools (createuser/createdb/psql) must talk to the
  # temporary local server over the Unix socket (auth-local=trust) as the bootstrap
  # superuser. The container inherits libpq vars from env_file/.env:
  #   - PGHOST=postgres     -> forces a TCP connection to a host the temp server
  #                            isn't listening on ("Connection refused")
  #   - PGUSER=openmaptiles -> connects AS a role that doesn't exist yet
  #                            ('role "openmaptiles" does not exist')
  #   - PGDATABASE=openmaptiles -> defaults to a database that doesn't exist yet
  # Clear them so libpq uses the local socket and connects as the OS user "postgres"
  # (the superuser initdb created) against the default "postgres" database.
  unset PGHOST PGHOSTADDR PGUSER PGDATABASE PGPASSWORD

  mkdir -p "$PGDATA"
  chown -R postgres:postgres /var/lib/postgresql
  chmod 700 "$PGDATA" || true

  if [[ ! -s "$PGDATA/PG_VERSION" ]]; then
    echo "Initializing PostgreSQL 17 data directory at $PGDATA"
    runuser -u postgres -- /usr/pgsql-17/bin/initdb \
      -D "$PGDATA" \
      --encoding=UTF8 \
      --auth-local=trust \
      --auth-host=scram-sha-256

    {
      echo "listen_addresses = '*'"
      echo "port = ${PGPORT}"
      echo "jit = off"
    } >> "$PGDATA/postgresql.conf"

    {
      echo "host all all 0.0.0.0/0 scram-sha-256"
      echo "host all all ::/0 scram-sha-256"
    } >> "$PGDATA/pg_hba.conf"

    echo "Starting temporary PostgreSQL for extension setup"
    runuser -u postgres -- /usr/pgsql-17/bin/pg_ctl \
      -D "$PGDATA" \
      -o "-c listen_addresses='localhost' -p ${PGPORT}" \
      -w start

    stop_temp_server() {
      runuser -u postgres -- /usr/pgsql-17/bin/pg_ctl -D "$PGDATA" -m fast -w stop
    }
    trap stop_temp_server EXIT

    escaped_password=${POSTGRES_PASSWORD//\'/\'\'}

    if [[ "$POSTGRES_USER" == "postgres" ]]; then
      runuser -u postgres -- /usr/pgsql-17/bin/psql \
        -p "$PGPORT" \
        -v ON_ERROR_STOP=1 \
        --dbname postgres \
        -c "ALTER USER postgres WITH PASSWORD '${escaped_password}';"
    else
      runuser -u postgres -- /usr/pgsql-17/bin/createuser \
        -p "$PGPORT" \
        --superuser \
        "$POSTGRES_USER" || true
      runuser -u postgres -- /usr/pgsql-17/bin/psql \
        -p "$PGPORT" \
        -v ON_ERROR_STOP=1 \
        --dbname postgres \
        -c "ALTER USER \"${POSTGRES_USER}\" WITH PASSWORD '${escaped_password}';"
    fi

    runuser -u postgres -- /usr/pgsql-17/bin/createdb \
      -p "$PGPORT" \
      -O "$POSTGRES_USER" \
      "$POSTGRES_DB" || true

    runuser -u postgres -- /usr/pgsql-17/bin/createdb \
      -p "$PGPORT" \
      template_postgis || true

    runuser -u postgres -- /usr/pgsql-17/bin/psql \
      -p "$PGPORT" \
      -v ON_ERROR_STOP=1 \
      --dbname postgres \
      -c "UPDATE pg_database SET datistemplate = true WHERE datname = 'template_postgis';"

    for db in template_postgis "$POSTGRES_DB"; do
      echo "Loading OpenMapTiles extensions into ${db}"
      runuser -u postgres -- /usr/pgsql-17/bin/psql \
        -p "$PGPORT" \
        -v ON_ERROR_STOP=1 \
        --dbname "$db" <<'EOSQL'
DROP EXTENSION IF EXISTS postgis_tiger_geocoder;
DROP EXTENSION IF EXISTS postgis_topology;

CREATE EXTENSION IF NOT EXISTS postgis;
CREATE EXTENSION IF NOT EXISTS fuzzystrmatch;
CREATE EXTENSION IF NOT EXISTS hstore;
CREATE EXTENSION IF NOT EXISTS unaccent;
CREATE EXTENSION IF NOT EXISTS osml10n;
CREATE EXTENSION IF NOT EXISTS gzip;
EOSQL
    done

    runuser -u postgres -- /usr/pgsql-17/bin/psql \
      -p "$PGPORT" \
      -v ON_ERROR_STOP=1 \
      --dbname postgres \
      -c "ALTER SYSTEM SET jit = 'off';"

    stop_temp_server
    trap - EXIT
    echo "PostgreSQL 17 OpenMapTiles dev database initialized"
  fi

  exec runuser -u postgres -- /usr/pgsql-17/bin/postgres -D "$PGDATA"
fi

exec "$@"
