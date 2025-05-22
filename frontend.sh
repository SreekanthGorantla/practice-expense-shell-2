#!/bin/bash

USERID=$(id -u)

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

######################################################
# Functions
######################################################
VALIDATE(){
    if [ $1 -ne 0 ]
    then
        echo -e "$2 ... $R FAILURE $N"
        exit 1
    else
        echo -e "$2 ... $G SUCCESS $N"
    fi
}

CHECK_ROOT(){
    if [ $USERID -ne 0 ]
    then
        echo "Error:: You need sudo access to execute this command"
        exit 1
    fi
}
##############################################################################
# Main
##############################################################################
LOG_FOLDER="/var/log/frontend-shell-2"
LOG_FILE=$(echo $0 | cut -d "." -f1)
TIMESTAMP=$(date +%Y-%m-%d-%H-%M-%S)
LOG_FILE_NAME="$LOG_FOLDER/$LOG_FILE-$TIMESTAMP.log"

echo ================================================================
mkdir -p $LOG_FOLDER &>> $LOG_FILE_NAME
echo ================================================================
echo "Script started executing at: $TIMESTAMP" &>> $LOG_FILE_NAME
echo ================================================================
CHECK_ROOT
echo ================================================================

dnf install nginx -y 

systemctl enable nginx

systemctl start nginx

rm -rf /usr/share/nginx/html/*

curl -o /tmp/frontend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-frontend-v2.zip

cd /usr/share/nginx/html

unzip /tmp/frontend.zip

vim /etc/nginx/default.d/expense.conf

systemctl restart nginx