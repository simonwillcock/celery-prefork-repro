#!/bin/bash
set -euo pipefail

init_db() {
  set +e

    # make sure there are no other connections
    docker exec --user=postgres c4_db_1 psql --command="SELECT pg_terminate_backend(pg_stat_activity.pid)
    FROM pg_stat_activity
    WHERE pg_stat_activity.datname = 'c4'
      AND pid <> pg_backend_pid();"
    docker exec --user=postgres c4_db_1 dropdb c4
    docker exec --user=postgres c4_db_1 dropuser celery4
    docker exec --user=postgres c4_db_1 createuser celery4
    docker exec --user=postgres c4_db_1 psql --command="ALTER USER celery4 WITH PASSWORD 'c4';"
    docker exec --user=postgres c4_db_1 psql --command="ALTER USER celery4 CREATEDB;"
    docker exec --user=postgres c4_db_1 createdb --owner=celery4 c4

    set -e

    # run migrations
    docker-compose run --rm -e DB_LOG_LEVEL=INFO app python manage.py migrate --noinput
}

full() {
    # Take down containers and remove volumes
    docker-compose down -v --remove-orphans

    # kill any running k3 containers
    docker-compose kill
    # clean up
    docker-compose rm -fv

    echo "--- Building all containers, this might take a while..."
    docker-compose build db broker app
    echo "--- Done"

    containers="$@"
    echo "--- Bringing up ${containers:-containers}..."

    if [[ -z "$containers" ]]; then
        docker-compose up -d db
        sleep 5
        docker-compose up -d app worker
    else
        # don't quote $containers, we want variable expansion
        docker-compose up -d $containers
    fi
    echo "--- Done"

    echo "--- Initialising Postgres and Elasticsearch..."

    init_db

    echo "--- Done"

    # clean up app run containers
    docker-compose rm -fv

    # finally print some status
    docker-compose ps
}

show_help() {
cat << EOF
Usage: ${0##*/} [full | fetch_dumps | npm_rebuild | restore_db | restore_es]

Arguments:
    full:           Run the full setup procedure which includes the above
                    commands. This will destroy your existing docker instances!
                    (optionally specify the containers to bring up)
EOF
}

cmd="${1:-}"
shift || true

case "$cmd" in
    -h|--help) show_help
        ;;
    full) full "$@"
        ;;
    *) show_help >&2; exit 1
        ;;
esac
