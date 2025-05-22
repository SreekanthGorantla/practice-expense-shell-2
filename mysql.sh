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
LOGS_FOLDER="/var/log/expense-logs2"
LOG_FILE=$(echo $0 | cut -d "." -f1)
TIMESTAMP=$(date +%Y-%m-%d-%H-%M-%S)
LOG_FILE_NAME="$LOGS_FOLDER/$LOG_FILE-$TIMESTAMP.log"

mkdir -p $LOGS_FOLDER  &>> $LOG_FILE_NAME
echo "Script started executing at: $TIMESTAMP" &>> $LOG_FILE_NAME

CHECK_ROOT

#############################################
# Install, Enable and Start mysql server
#############################################
dnf install mysql-server -y &>> $LOG_FILE_NAME
VALIDATE $? "Installing MySQL-server"
echo ================================================================

systemctl enable mysqld &>> $LOG_FILE_NAME
VALIDATE $? "Enable mysqld"
echo ================================================================

systemctl start mysqld &>> $LOG_FILE_NAME
VALIDATE $? "Start mysqld"
echo ================================================================

##############################################################################
# Setup MySQL root password setup
##############################################################################
mysql -h mysql.sreeaws.space -u root -pExpenseApp@1 -e 'show databases;' &>> $LOG_FILE_NAME

if [ $? -ne 0 ]
then
    echo "MySQL root password not setup" &>> $LOG_FILE_NAME
    mysql_secure_installation --set-root-pass ExpenseApp@1
    VALIDATE $? "Setting root password"
else
    echo -e "MySQL Root password already setup ... $Y SKIPPING $N"
fi
echo ================================================================