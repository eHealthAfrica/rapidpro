#!/bin/bash
set -e


# Define help message
show_help() {
    echo """
    Commands
    manage     : Invoke django manage.py commands
    setuplocaldb  : Create local database
    setupproddb : Create prod database
    """
}

setup_local_db() {
    set +e
    psql -U $RDS_USERNAME -h $RDS_HOSTNAME template_postgis -c 'CREATE EXTENSION hstore;'
    psql -U $RDS_USERNAME -h $RDS_HOSTNAME template1 -c 'CREATE EXTENSION hstore;'
    psql -U $RDS_USERNAME -h $RDS_HOSTNAME template_postgis -c 'CREATE EXTENSION postgis;'
    psql -U $RDS_USERNAME -h $RDS_HOSTNAME template1 -c 'CREATE EXTENSION postgis;'
    cd /code
    python manage.py sqlcreate | psql -U $RDS_USERNAME -h $RDS_HOSTNAME
    set -e
    python manage.py migrate
}

setup_prod_db() {
    set +e
    PGPASSWORD=$RDS_PASSWORD psql -U $RDS_USERNAME -h $RDS_HOSTNAME $RDS_DB_NAME -c 'CREATE EXTENSION hstore;'
    PGPASSWORD=$RDS_PASSWORD psql -U $RDS_USERNAME -h $RDS_HOSTNAME $RDS_DB_NAME -c 'CREATE EXTENSION postgis;'
    cd /code
    set -e
    python manage.py migrate
}

start_app() {
    cd /code
    python manage.py collectstatic --noinput
    chown www-data:www-data -R /var/www/static/
    supervisord -c /etc/supervisor/supervisord.conf -n
}

case "$1" in
    manage )
        cd /code/
        python manage.py "${@:2}"
    ;;
    setuplocaldb )
        setup_local_db
    ;;
    setupproddb )
        setup_prod_db
    ;;
    start )
        setup_local_db
        start_app
    ;;
    start_prod )
        setup_prod_db
        start_app
    ;;
    bash )
        bash
    ;;
    *)
        show_help
    ;;
esac
