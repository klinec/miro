#!/bin/bash

############################################################################
# get variables from input
BRANCH=$1

if [[ -z "$BRANCH" ]]
then 
    BRANCH='master'
fi

############################################################################
# set some other defaults
#consule colors!
RED="\033[0;31m"
GRN="\033[0;32m"
WHT="\033[1;37m"
NON="\033[0m"

function e {
    if [ $1 -ne 0 ]; then
        echo -e "$RED $3 $NON"
    else
        echo -e "$GRN $2 $NON" 
    fi
}


############################################################################
## project custom environment setup
echo 'starting the updated biach ###########################'
git stash
git fetch
git branch -D $BRANCH > /dev/null 2>&1
git checkout origin/$BRANCH -b $BRANCH
echo "git checkout origin/$BRANCH -b $BRANCH"
git stash pop

#############################################################################
## application setup
if [ ! -f ../composer.phar ];then
    echo 'Downloading composer ###########################'
    curl  https://getcomposer.org/installer | php
    e $? 'DONE' 'FAILED'
fi

echo 'Installing/updating project dependencies ################'
php composer.phar install
e $? 'DONE' 'FAILED'

############################################################################
## symfony folder permissions

echo 'Cleaning logs  ###########################'
rm -rf ../app/cache/*
rm -rf ../app/logs/*
e $? 'DONE' 'FAILED'


