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
        echo -2 "$2 ... $G SUCCESS $N"
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
LOG_FOLDER="/var/log/expense-shell-2"
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




dnf module disable nodejs -y

dnf module enable nodejs:20 -y

dnf install nodejs -y


useradd expense

mkdir /app

curl -o /tmp/backend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-backend-v2.zip

cd /app

npm install

vim /etc/systemd/system/backend.service

systemctl daemon-reload

systemctl start backend

systemctl enable backend

dnf install mysql -y

mysql -h <MYSQL-SERVER-IPADDRESS> -uroot -pExpenseApp@1 < /app/schema/backend.sql

systemctl restart backend