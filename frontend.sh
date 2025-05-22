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


mkdir -p $LOG_FOLDER
echo =====================================================
echo "Script started executing at: $TIMESTAMP" &>> $LOG_FILE_NAME
echo =====================================================
CHECK_ROOT
echo =====================================================

############################################
# Install, enable and start Nginx
############################################
dnf install nginx -y  &>> $LOG_FILE_NAME
VALIDATE $? "Installing Nginx"
echo =====================================================

systemctl enable nginx &>> $LOG_FILE_NAME
VALIDATE $? "Enabling Nginx"
echo =====================================================

systemctl start nginx &>> $LOG_FILE_NAME
VALIDATE $? "Starting Nginx"
echo =====================================================

#############################################################
# Removing existing version of code from /usr/share/nginx/html
#############################################################
rm -rf /usr/share/nginx/html/*
VALIDATE $? "Removing existing version of code"
echo =====================================================

############################################
# Downloading frontend code
############################################
curl -o /tmp/frontend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-frontend-v2.zip
VALIDATE $? "Downloading frontend code"
echo =====================================================

############################################
# Moving HTML directory
############################################
cd /usr/share/nginx/html  &>> $LOG_FILE_NAME
VALIDATE $? "Moving to HTML directory"
echo =====================================================

############################################
# Unzipping Frontend code
############################################
unzip /tmp/frontend.zip  &>> $LOG_FILE_NAME
VALIDATE $? "Unzipping frontend code"
echo =====================================================

############################################
# copy expense.conf to /etc/nginx/default.d
############################################
cp /home/ec2-user/practice-expense-shell-2/expense.conf /etc/nginx/default.d/expense.conf
VALIDATE $? "Copy expense conf file"
echo =====================================================

############################################
# Restart Nginx
############################################
systemctl restart nginx  &>> $LOG_FILE_NAME
VALIDATE $? "Restart Nginx"
echo =====================================================