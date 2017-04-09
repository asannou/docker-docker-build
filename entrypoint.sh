#!/bin/sh
set -e

if [ $# -eq 1 ]
then
  IMAGE=$1
  shift
else
  while [ "$1" != '--' ]
  do
    [ -z "$1" ] && exit
    OPTIONS="$OPTIONS $1"
    shift
  done
  IMAGE=$2
  shift 2
fi

DOCKER='docker -H unix:///docker.sock'

SELF=$($DOCKER inspect --format='{{.Config.Image}}' $HOSTNAME)
PREFIX=$(echo $SELF | cut -d : -f 1)
TAG=$(echo $SELF | cut -d : -f 2)

sed -i -e "s#{{image}}#$PREFIX/$IMAGE#" /etc/nginx/proxy.conf
nginx -c /etc/nginx/proxy.conf

[ -z "$($DOCKER images -q $IMAGE)" ] && $DOCKER pull $IMAGE

WD=$($DOCKER inspect --format='{{.Config.WorkingDir}}' $IMAGE)
[ -z "$WD" ] && WD=/root

ID=$($DOCKER create -v $WD $IMAGE /bin/true)
trap "$DOCKER rm $ID > /dev/null" INT EXIT

$DOCKER run -a stderr --rm --link $HOSTNAME:host --volumes-from $ID -w $WD docker -H host build -t $IMAGE .

[ "$TAG" = 'run' ] && $DOCKER run $OPTIONS $PREFIX/$IMAGE "$@"
