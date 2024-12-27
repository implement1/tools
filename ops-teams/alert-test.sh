#!/bin/bash
# This will send an alert into Alertmanager and then resolve it after you press
# enter.
host=$1
name="test alert please ignore"
url='http://alerts.trp.co:9093/api/v1/alerts'

if [ "$#" -ne 1 ]; then
	echo "USAGE: ./alert-test.sh HOSTNAME"
	echo "EXAMPLE: ./alert-test.sh ord.test"
	exit 1
fi

echo "sending test alert for $host"

curl -XPOST $url -d "[{
	\"status\": \"firing\",
	\"labels\": {
		\"client\": \"test-script\",
		\"alertname\": \"$name\",
		\"status\":\"critical\",
		\"host\": \"$host\",
		\"key\": \"$host\"
	},
	\"annotations\": {
		\"summary\": \"test alert please ignore\"
}
}]"

echo ""

echo "press enter to resolve alert"
read

echo "sending resolve"
curl -XPOST $url -d "[{
  \"status\": \"resolved\",
	\"labels\": {
		\"client\": \"test-script\",
		\"alertname\": \"$name\",
		\"status\":\"critical\",
		\"host\": \"$host\",
		\"key\": \"$host\"
	},
	\"annotations\": {
		\"summary\": \"test alert please ignore\"
}
}]"

echo ""
