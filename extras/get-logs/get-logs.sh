#!/bin/bash

echo "Getting Allure TestOps version from .env"
TESTOPS_VERSION=$(awk 'BEGIN{FS="="} /^VERSION/ {print $2}' .env)
echo "Allure TestOps version from .env is $TESTOPS_VERSION"


echo "Getting Allure TestOps version from .env"



#getting the list of all the docker containers

SERVICES_LIST=$(docker-compose config --services)

echo "Trying to get the log for these services: "
echo "${SERVICES_LIST}"

TIME_STAMP=$(date +%Y%m%d-%H%M%S)

for SERVICE in $SERVICES_LIST
do
  docker-compose logs $SERVICE > $SERVICE-logs-$TIME_STAMP.txt
  echo "Saved logs to $SERVICE-logs-${TIME_STAMP}.txt"
done

# getting data on the queues in RabbitMQ

RABBIT_LOG=$(docker-compose exec -u root report-mq rabbitmqctl list_queues -p report)

cat << EOF >> rabbit-queues-${TIME_STAMP}.txt
${RABBIT_LOG}
EOF

echo "Saved logs to rabbit-queues-${TIME_STAMP}.txt"


echo "Getting environement information" 

echo "### Creating file with the environment info ${TIME_STAMP}"
ENV_FILE=env-$TIME_STAMP.txt

echo "### Creating file with the environment info for Allure TestOps troubleshooting" > $ENV_FILE

echo "### Saving RAM info as 'free -h | grep -v +'"
free -h | grep -v +  | tee -a $ENV_FILE
echo "### Saving RAM info from top command" | tee -a $ENV_FILE
top -n 1 -b | sed -n '1,6p'| tee -a $ENV_FILE

# cat /etc/os-release | grep 'NAME\|VERSION' | grep -v 'VERSION_ID' | grep -v 'PRETTY_NAME'
# uname -m

echo "### Saving storage information" | tee -a $ENV_FILE
df -h --total | tee -a $ENV_FILE
echo "### Saving inodes information" | tee -a $ENV_FILE
df -i | tee -a $ENV_FILE

echo "### Getting the HW listing (CPU via lscpu)" | tee -a $ENV_FILE
lscpu | grep 'Architecture\|CPU(s)\|CPU max MHz' | tee -a $ENV_FILE
echo "### Getting the HW listing (CPU, RAM, Network via lshw)" | tee -a $ENV_FILE
lshw | grep -E -i "(\-cpu|\-memory|size|network|capacity)" | tee -a $ENV_FILE


# creating single archive
ARCHIVE=$(date +%Y%m%d-%H%M)-testops-$TESTOPS_VERSION.tar.gz
echo "Creating single archive with all logs - ${ARCHIVE}"

tar czf ./${ARCHIVE} ./*.txt

if [ "$?" -eq "0" ]
then
  rm -f ./*.txt
fi


echo "Now, you can restart your Allure TestOps installation"
echo "1. docker-compose down"
echo "2. docker-compose up -d"