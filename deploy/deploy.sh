#!/bin/sh
set -e

echo "Installing Zabbix packages..."

apk add --allow-untrusted \
  zabbix-agent \
  zabbix-proxy

echo "Zabbix installed successfully"

zabbix_agentd --version