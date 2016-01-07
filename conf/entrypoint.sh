#!/bin/bash
set -e


# Define help message
show_help() {
    echo """
    Commands
    manage     : Invoke django manage.py commands
    setupdb  : Create empty database for rapidpro, will still need migrations run
    """
}

setup_db() {
    psql -U postgres -h db template_postgis -c 'CREATE EXTENSION hstore;'
    psql -U postgres -h db template1 -c 'CREATE EXTENSION hstore;'
    psql -U postgres -h db template_postgis -c 'CREATE EXTENSION postgis;'
    psql -U postgres -h db template1 -c 'CREATE EXTENSION postgis;'
    cd /code
    python manage.py sqlcreate | psql -U postgres -h db
    python manage.py migrate
}

case "$1" in
    manage )
        cd /code/
        python manage.py "${@:2}"
    ;;
    setupdb )
        set +e
        setup_db
    ;;
    start )
        setup_db
        cd /code
        python manage.py collectstatic --noinput
        /usr/local/bin/supervisord -c /etc/supervisor/supervisord.conf
        nginx -g "daemon off;"
    ;;
    *)
        show_help
    ;;
esac
