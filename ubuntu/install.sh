#!/bin/sh

#move to script directory so all relative paths work
cd "$(dirname "$0")"

#includes
. ./resources/config.sh
. ./resources/colors.sh
. ./resources/environment.sh

# removes the cd img from the /etc/apt/sources.list file (not needed after base install)
sed -i '/cdrom:/d' /etc/apt/sources.list

#Update to latest packages
verbose "Update installed packages"
apt-get update && apt-get upgrade -y

#Add dependencies
apt-get install -y wget
apt-get install -y lsb-release
apt-get install -y systemd
apt-get install -y systemd-sysv
apt-get install -y ca-certificates
apt-get install -y dialog
apt-get install -y nano
apt-get install -y nginx
apt-get install -y build-essential

#SNMP
apt-get install -y snmpd
echo "rocommunity public" > /etc/snmp/snmpd.conf
service snmpd restart

#IPTables
resources/iptables.sh

#sngrep
resources/sngrep.sh

#FusionPBX
resources/fusionpbx.sh

#PHP
resources/php.sh

#NGINX web server
resources/nginx.sh

#Postgres
# Prompt user for remote PostgreSQL details
verbose "Please enter the details for the remote PostgreSQL server:"
echo -n "Enter PostgreSQL host: "
read database_host
echo -n "Enter PostgreSQL port (default: 5432): "
read database_port
database_port=${database_port:-5432}
echo -n "Enter PostgreSQL database name: "
read database_name
echo -n "Enter PostgreSQL user: "
read database_user
echo -n "Enter PostgreSQL password: "
read -s database_password
echo

# Export database details
export DATABASE_HOST="$database_host"
export DATABASE_PORT="$database_port"
export DATABASE_NAME="$database_name"
export DATABASE_USER="$database_user"
export DATABASE_PASSWORD="$database_password"

#Optional Applications
resources/applications.sh

#FreeSWITCH
resources/switch.sh

#Fail2ban
resources/fail2ban.sh

#set the ip address
server_address=$(hostname -I)

#add the database schema, user and groups
resources/finish.sh
