#!/bin/sh
set -e

while [ "$1" != '--' ]
do
  [ -z "$1" ] && exit
  OPTIONS="$OPTIONS $1"
  shift
done

IMAGE=$2
shift 2

nginx -c /etc/nginx/proxy.conf

DOCKER='docker -H unix:///docker.sock'
[ -z "$($DOCKER images -q $IMAGE)" ] && $DOCKER pull $IMAGE
WD=$($DOCKER inspect --format='{{.Config.WorkingDir}}' $IMAGE)
[ -z "$WD" ] && WD=/root
ID=$($DOCKER create -v $WD $IMAGE /bin/true)
trap "$DOCKER rm $ID > /dev/null" INT EXIT
$DOCKER run -a stderr --rm --link $HOSTNAME:host --volumes-from $ID -w $WD docker -H host build -t $IMAGE .
$DOCKER run $OPTIONS 0_$IMAGE "$@"
