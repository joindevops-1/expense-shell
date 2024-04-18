#!/bin/bash

USERID=$(id -u)
DATE=$(date +%F-%M-%S)
LOGFILE=$(echo $0 | cut -d "." -f1)
LOG=/tmp/$LOGFILE-$DATE.log
R="\e[31m"
G="\e[32m"
N="\e[0m"
echo "Please enter MySQL root password:"
read -s mysql_root_password

VALIDATE(){
    if [ $1 -ne 0 ]
    then
        echo -e "$2...$R FAILURE $N"
        exit 1
    else
        echo -e "$2...$G SUCCESS $N"
    fi
}

if [ $USERID -ne 0 ]
then
    echo "Please run this script with root access."
    exit 1 # manually exit if error comes.
else
    echo "You are super user."
fi

dnf install mysql-server -y &>>$LOG
VALIDATE $? "MySQL Server Installation"

systemctl enable mysqld &>>$LOG
VALIDATE $? "Enabled MySQL Server"

systemctl start mysqld &>>$LOG
VALIDATE $? "Started MySQL Server"

mysql -h db.daws78s.online -u root -p${mysql_root_password} -e 'show databases' &>>$LOG
if [ $? -ne 0 ]
then
    mysql_secure_installation --set-root-pass ${mysql_root_password}
    VALIDATE $? "Root password Setup"
else
    echo "Root password already setup"
fi
