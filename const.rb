#!/usr/bin/env ruby
# -*- coding: utf-8 -*-

HOST_MASTER="vm2"
HOST_MASTER_IP=`getent ahosts #{HOST_MASTER} RAW`.lines.first.split(' ')[0]
PORT_SSH_MASTER="22"
PORT_PSQL_MASTER="5432"
SYNC_MASTER="on"

HOST_SLAVE="vm3"
HOST_SLAVE_IP=`getent ahosts #{HOST_SLAVE} RAW`.lines.first.split(' ')[0]
PORT_SSH_SLAVE="22"
PORT_PSQL_SLAVE="5433"
HOT_STANDBY_SLAVE="on"

HOST_PGPOOL="vm4"
HOST_PGPOOL_IP=`getent ahosts #{HOST_PGPOOL} RAW`.lines.first.split(' ')[0]
PORT_SSH_PGPOOL="22"

PSQL_URI="ftp.postgresql.org"
PSQL_URI_GET="pub/source/v9.2.3/postgresql-9.2.3.tar.bz2"
PSQL_ARCHIVE="pgsql.tar.bz2"
PSQL_OLD_DIR="postgresql-9.2.3"
PSQL_USER="postgres"
PSQL_GROUP="postgres"

INSTALL_FOLDER="/install"
PSQL_FOLDER="/srv/psql"

