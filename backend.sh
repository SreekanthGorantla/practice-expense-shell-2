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
LOG_FOLDER="/var/log/backend-shell-2"
LOG_FILE=$(echo $0 | cut -d "." -f1)
TIMESTAMP=$(date +%Y-%m-%d-%H-%M-%S)
LOG_FILE_NAME="$LOG_FOLDER/$LOG_FILE-$TIMESTAMP.log"

#########################################################
# create or replace log file directory
#########################################################
mkdir -p $LOG_FOLDER
echo =====================================================
echo "Script started executing at: $TIMESTAMP" &>> $LOG_FILE_NAME
echo =====================================================
CHECK_ROOT
echo =====================================================

##########################################
# disable,enable nodejs version
##########################################
dnf module disable nodejs -y  &>> $LOG_FILE_NAME
VALIDATE $? "Disable existing Nodejs"
echo =====================================================

dnf module enable nodejs:20 -y  &>> $LOG_FILE_NAME
VALIDATE $? "Enable latest Nodejs"
echo =====================================================

##########################################
# Install nodejs version
##########################################
dnf install nodejs -y  &>> $LOG_FILE_NAME
VALIDATE $? "Install latest Nodejs"
echo =====================================================

##########################################
# Add expense user
##########################################
id expense  &>> $LOG_FILE_NAME
if [ $? -ne 0 ]
then
    useradd expense  &>> $LOG_FILE_NAME
    VALIDATE $? "Adding expense user"
else
    echo -e "Expense user already exists ... $Y SKIPPING $N"
fi
echo =====================================================

##########################################
# Create /app directory
##########################################
mkdir /app  &>> $LOG_FILE_NAME
VALIDATE $? "Creating app directory"
echo =====================================================

##########################################
# Download backend
##########################################
curl -o /tmp/backend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-backend-v2.zip  &>> $LOG_FILE_NAME
VALIDATE $? "Downloading backed"
echo =====================================================

##########################################
# Remove everything from /app folder
##########################################
cd /app
rm -rf /app/*
echo =====================================================

##########################################
# Remove everything from /app folder
##########################################
unzip /tmp/backend.zip   &>> $LOG_FILE_NAME
VALIDATE $? "Unzipping backend code"
echo =====================================================

##########################################
# Install npm dependencies
##########################################
npm install  &>> $LOG_FILE_NAME
VALIDATE $? "Installing Dependencies"
echo =====================================================

####################################################################################
# Copy backend.service to /etc/systemd/system
####################################################################################
cp /home/ec2-user/practice-expense-shell-2/backend.service /etc/systemd/system/backend.service
VALIDATE $? "Copy backend.service"
echo =====================================================

##########################################
# Prepare MySQL backend
##########################################
dnf install mysql -y  &>> $LOG_FILE_NAME
VALIDATE $? "Install mysql on backend"

mysql -h mysql.sreeaws.space -uroot -pExpenseApp@1 < /app/schema/backend.sql &>> $LOG_FILE_NAME
VALIDATE $? "Setting up transactions schema"
echo =====================================================

systemctl daemon-reload  &>> $LOG_FILE_NAME
VALIDATE $? "Deamon reload"
echo =====================================================

systemctl enable backend  &>> $LOG_FILE_NAME
VALIDATE $? "Enable backend service"
echo =====================================================

systemctl restart backend  &>> $LOG_FILE_NAME
VALIDATE $? "Start backend service"
echo =====================================================