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

dnf module disable nodejs -y &>>$LOG
VALIDATE $? "Disabled default nodejs"

dnf module enable nodejs:20 -y &>>$LOG
VALIDATE $? "Enabled nodejs:20"

dnf install nodejs -y &>>$LOG
VALIDATE $? "NodeJS Installation"

id expense &>>$LOG
if [ $? -ne 0 ]
then
    useradd expense &>>$LOG
fi

curl -o /tmp/backend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-backend-v2.zip &>>$LOG
VALIDATE $? "Downloaded Backend Code"

mkdir /app  &>>$LOG
VALIDATE $? "app directory created"

cd /app &>>$LOG
VALIDATE $? "Moved to app directory"

unzip /tmp/backend.zip  &>>$LOG
VALIDATE $? "Extracted code"

npm install   &>>$LOG
VALIDATE $? "Installed NodeJS dependencies"

cp /home/ec2-user/expense-shell/backend.service /etc/systemd/system/backend.service
VALIDATE $? "Copied backend service"

systemctl daemon-reload &>>$LOG
VALIDATE $? "Realoaded systemctl daemon"

systemctl start backend &>>$LOG
VALIDATE $? "Started Backend service"

systemctl enable backend &>>$LOG
VALIDATE $? "Enabled Backend service"

dnf install mysql -y &>>$LOG
VALIDATE $? "Installed MySQL Client"

mysql -h db.daws78s.online -uroot -p${mysql_root_password} < /app/schema/backend.sql &>>$LOG
VALIDATE $? "MySQL schema loaded"

systemctl restart backend &>>$LOG
VALIDATE $? "Restarted backend service"



