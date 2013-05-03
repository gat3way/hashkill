#!/bin/bash

ERRORS=0
TESTS=0
PARAM="$1"
echo -e "Performing tests...\n"

#$COMMAND 2>output >&2 > runtest.sh </dev/console;

while IFS='|' read -r TEST_TARGET TEST_NEEDLE TEST_COMMAND
do
tput sgr0
COMMAND="$TEST_COMMAND $PARAM"
echo -en "Testing $TEST_TARGET";
$COMMAND 2>output >&2 > runtest.sh < dummy;
RESULT=`grep "$TEST_NEEDLE" output`;
TESTS=`expr $TESTS + 1`
if [ ! -z "$RESULT" ]; then
    echo -e '\E[32m Success'
    tput sgr0
else
    ERRORS=`expr $ERRORS + 1`
    echo -e '\E[31m FAILURE!'
    tput sgr0
fi
done < test.dat

echo -en "\n\n$TESTS tests performed, $ERRORS errors found.\n\n"
return $ERRORS