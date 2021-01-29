#!/bin/sh

if [ -n "$1" ] ; then
    TESTSUITE_PORT=$1
fi

if [ -n "$2" ] ; then
    SERVER="--server $2"
    PMA_HOST=$2
else
    SERVER=''
fi

# Set PHPMyAdmin environment
PHPMYADMIN_HOSTNAME=${TESTSUITE_HOSTNAME:=localhost}
PHPMYADMIN_PORT=${TESTSUITE_PORT:=80}
PHPMYADMIN_URL=http://${PHPMYADMIN_HOSTNAME}:${PHPMYADMIN_PORT}/

# Set database environment
PHPMYADMIN_DB_HOSTNAME=${PMA_HOST:=localhost}
PHPMYADMIN_DB_PORT=${PMA_PORT:=3306}

# Find test script
if [ -f ./phpmyadmin_test.py ] ; then
    FILENAME=./phpmyadmin_test.py
else
    FILENAME=./testing/phpmyadmin_test.py
fi

mysql -h "${PHPMYADMIN_DB_HOSTNAME}" -P"${PHPMYADMIN_DB_PORT}" -u"${TESTSUITE_USER:=root}" -p"${TESTSUITE_PASSWORD}" -e "SELECT @@version;" > /dev/null
ret=$?

if [ $ret -ne 0 ] ; then
    echo "Could not connect to ${PHPMYADMIN_DB_HOSTNAME}"
    exit $ret
fi

# Perform tests
ret=0
pytest -p no:cacheprovider -q --url "$PHPMYADMIN_URL" --username ${TESTSUITE_USER:=root} --password "$TESTSUITE_PASSWORD"  $SERVER $FILENAME
ret=$?

# Show debug output in case of failure
if [ $ret -ne 0 ] ; then
    ${COMMAND_HOST} ps faux
    echo "Result of ${PHPMYADMIN_DB_HOSTNAME} tests: FAILED"
    exit $ret
fi

echo "Result of ${PHPMYADMIN_DB_HOSTNAME} tests: SUCCESS"
