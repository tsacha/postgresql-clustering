#!/usr/bin/env ruby
# -*- coding: utf-8 -*-

load "#{File.dirname(__FILE__)}/const.rb"
require 'fileutils'

STDOUT.sync = true

# Configuration de la machine maître

Dir.chdir(PSQL_FOLDER)

FileUtils.rm_r("./data") if FileTest.directory?('./data/')
`killall -9 postgres`

system("su - #{PSQL_USER} -c '#{PSQL_FOLDER}/bin/initdb #{PSQL_FOLDER}/data/'")

system("su - #{PSQL_USER} -c '#{PSQL_FOLDER}/bin/pg_ctl -D #{PSQL_FOLDER}/data/ start > logfile 2>&1'")

`su - #{PSQL_USER} -c '#{PSQL_FOLDER}/bin/psql -U postgres -p #{PORT_PSQL_MASTER} -c "CREATE USER replication REPLICATION LOGIN ENCRYPTED PASSWORD 'replication';"'`
system("#{PSQL_FOLDER}/bin/pg_basebackup -U postgres -D - -P -Ft | bzip2 > /tmp/pg_basebackup.tar.bz2")
# TODO
# Création de l'utilsateur réplication
# start backup
# tar
# stop backup
# tar >> host
