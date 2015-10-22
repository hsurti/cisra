#!/bin/bash
#title           :wildfly-install.sh
#description     :The script to install Wildfly 9.x

WILDFLY_VERSION=9.0.1.Final
WILDFLY_FILENAME=wildfly-$WILDFLY_VERSION
WILDFLY_ARCHIVE_NAME=$WILDFLY_FILENAME.tar.gz
WILDFLY_DOWNLOAD_ADDRESS=http://download.jboss.org/wildfly/$WILDFLY_VERSION/$WILDFLY_ARCHIVE_NAME

INSTALL_DIR=/opt
WILDFLY_FULL_DIR=$INSTALL_DIR/$WILDFLY_FILENAME
WILDFLY_DIR=$INSTALL_DIR/wildfly
WILDFLY_USER="cloud-user"
WILDFLY_SERVICE="wildfly"

WILDFLY_STARTUP_TIMEOUT=240
WILDFLY_SHUTDOWN_TIMEOUT=30

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
      
sudo yum install -y java-1.7.0-openjdk

if [[ $EUID -ne 0 ]]; then
  echo "This script must be run as root."
  exit 1
fi

echo "Downloading: $WILDFLY_DOWNLOAD_ADDRESS..."
[ -e "$WILDFLY_ARCHIVE_NAME" ] && echo 'Wildfly archive already exists.'
if [ ! -e "$WILDFLY_ARCHIVE_NAME" ]; then
  wget -q $WILDFLY_DOWNLOAD_ADDRESS
  if [ $? -ne 0 ]; then
     echo "Not possible to download Wildfly."
     exit 1
  fi
fi

echo "Cleaning up..."
rm -f "$WILDFLY_DIR"
rm -rf "$WILDFLY_FULL_DIR"
rm -rf "/var/run/$WILDFLY_SERVICE/"
rm -f "/etc/init.d/$WILDFLY_SERVICE"

echo "Installation..."
mkdir $WILDFLY_FULL_DIR
tar -xzf $WILDFLY_ARCHIVE_NAME -C $INSTALL_DIR
ln -s $WILDFLY_FULL_DIR/ $WILDFLY_DIR
useradd -s /sbin/nologin $WILDFLY_USER
chown -R $WILDFLY_USER:$WILDFLY_USER $WILDFLY_DIR
chown -R $WILDFLY_USER:$WILDFLY_USER $WILDFLY_DIR/

echo "Registrating Wildfly as service..."
# if Debian-like distribution
if [ -r /lib/lsb/init-functions ]; then
  cp $WILDFLY_DIR/bin/init.d/wildfly-init-debian.sh /etc/init.d/$WILDFLY_SERVICE
  sed -i -e 's,NAME=wildfly,NAME='$WILDFLY_SERVICE',g' /etc/init.d/$WILDFLY_SERVICE
  WILDFLY_SERVICE_CONF=/etc/default/$WILDFLY_SERVICE
fi

# if RHEL-like distribution
if [ -r /etc/init.d/functions ]; then
  cp $WILDFLY_DIR/bin/init.d/wildfly-init-redhat.sh /etc/init.d/$WILDFLY_SERVICE
  WILDFLY_SERVICE_CONF=/etc/default/wildfly.conf
fi



      

echo "Configuring application server..."
sed -i -e 's,<deployment-scanner path="deployments" relative-to="jboss.server.base.dir" scan-interval="5000",<deployment-scanner path="deployments" relative-to="jboss.server.base.dir" scan-interval="5000" deployment-timeout="'$WILDFLY_STARTUP_TIMEOUT'",g' $WILDFLY_DIR/standalone/configuration/standalone.xml
sed -i -e 's,<inet-address value="${jboss.bind.address:127.0.0.1}"/>,<any-address/>,g' $WILDFLY_DIR/standalone/configuration/standalone.xml
sed -i -e 's,<socket-binding name="ajp" port="${jboss.ajp.port:8009}"/>,<socket-binding name="ajp" port="${jboss.ajp.port:28009}"/>,g' $WILDFLY_DIR/standalone/configuration/standalone.xml
sed -i -e 's,<socket-binding name="http" port="${jboss.http.port:8080}"/>,<socket-binding name="http" port="${jboss.http.port:28080}"/>,g' $WILDFLY_DIR/standalone/configuration/standalone.xml
sed -i -e 's,<socket-binding name="https" port="${jboss.https.port:8443}"/>,<socket-binding name="https" port="${jboss.https.port:28443}"/>,g' $WILDFLY_DIR/standalone/configuration/standalone.xml
sed -i -e 's,<socket-binding name="osgi-http" interface="management" port="8090"/>,<socket-binding name="osgi-http" interface="management" port="28090"/>,g' $WILDFLY_DIR/standalone/configuration/standalone.xml
        
sudo /$WILDFLY_DIR/bin/standalone.sh

echo "Done."
