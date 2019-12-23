#!/bin/sh

#
# This is a simple script that allows the same container to be used for the app,
# worker, and scheduler components, without encoding complicataed commands into
# the startup.
#
set -e

cmd=${1:-true}
if [ "$#" -gt 0 ]; then shift; fi

export PYTHONPATH="/code/:${PYTHONPATH}"

case "$cmd" in

    dev_app)
        exec python manage.py runserver 0.0.0.0:8000
    ;;

    dev_worker)
        exec celery worker -A celery4_prefork -l info --concurrency=4
    ;;

    shell)
        exec python manage.py shell_plus
    ;;

    *) exec "$cmd" "$@"
esac
