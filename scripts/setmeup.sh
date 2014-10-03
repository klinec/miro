#!/bin/bash

############################################################################
# get variables from input
PROJECT=$1
DOC_ROOT=$2
SRC_ROOT=$3
REPOSITORY=$4

if [[ -z "$PROJECT" ]]
then 
    usage
    exit 1
fi

if [[ -z "$DOC_ROOT" ]]
then 
    usage
    exit 1
fi

if [[ -z "$SRC_ROOT" ]]
then 
    usage
    exit 1
fi

if [[ -z "$REPOSITORY" ]]
then
    usage
    exit 1
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
echo 'Project custom environment setup ###########################'

###your variables come here


e $? 'DONE' 'FAILED'


#############################################################################
## application setup
cd $SRC_ROOT$PROJECT
if [ ! -f $SRC_ROOT$PROJECT/composer.phar ];then
    echo 'Downloading composer ###########################'
    curl  https://getcomposer.org/installer | php
    e $? 'DONE' 'FAILED'
fi

echo 'Installing/updating project dependencies ################'
if [ ! -d $SRC_ROOT$PROJECT/vendor ];then
    php composer.phar install
else
    php composer.phar update
fi
e $? 'DONE' 'FAILED'

############################################################################
## symfony folder permissions

echo 'Adjusting the folder permissions  ###########################'

rm -rf $SRC_ROOT$PROJECT/app/cache
rm -rf $SRC_ROOT$PROJECT/app/logs

mkdir -p $SRC_ROOT$PROJECT/app/cache
mkdir -p $SRC_ROOT$PROJECT/app/logs

setfacl -R -m u:www-data:rwx -m u:`whoami`:rwx a $SRC_ROOT$PROJECT/app/cache  $SRC_ROOT$PROJECT/app/logs
setfacl -dR -m u:www-data:rwx -m u:`whoami`:rwx  $SRC_ROOT$PROJECT/app/cache  $SRC_ROOT$PROJECT/app/logs
e $? 'DONE' 'FAILED'

############################################################################
## make symlinks

echo 'Symlink the docroot  ###########################'
rm $DOC_ROOT$PROJECT
ln -s $SRC_ROOT$PROJECT/web $DOC_ROOT$PROJECT
e $? 'DONE' 'FAILED'



#check if everyting is configured properly
php $SRC_ROOT$PROJECT/app/check.php
