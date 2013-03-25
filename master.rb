#!/usr/bin/env ruby
# -*- coding: utf-8 -*-

load "#{File.dirname(__FILE__)}/const.rb"
require 'fileutils'

STDOUT.sync = true

# Configuration de la machine maître

Dir.chdir(PSQL_FOLDER)

`killall -9 postgres`
FileUtils.rm_r("./data") if FileTest.directory?('./data/')

system("su - #{PSQL_USER} -c '#{PSQL_FOLDER}/bin/initdb #{PSQL_FOLDER}/data/'")
FileUtils.chown_R PSQL_USER,PSQL_GROUP, PSQL_FOLDER+'/conf/'
system("su - #{PSQL_USER} -c 'cp -R #{PSQL_FOLDER}/conf/* #{PSQL_FOLDER}/data/'")

system("su - #{PSQL_USER} -c '#{PSQL_FOLDER}/bin/pg_ctl -w -D #{PSQL_FOLDER}/data/ start'")


`#{PSQL_FOLDER}/bin/psql -U postgres -p #{PORT_PSQL_MASTER} -c "SET LOCAL synchronous_commit TO OFF; CREATE USER replication REPLICATION LOGIN ENCRYPTED PASSWORD 'replication';"`
system("#{PSQL_FOLDER}/bin/pg_basebackup -U postgres -D - -P -Ft | bzip2 | ssh -o StrictHostKeychecking=no #{PSQL_USER}@#{HOST_SLAVE} -i #{PSQL_FOLDER}/.ssh/id_rsa 'cat - > /tmp/pg_basebackup.tar.bz2'")

system("#{PSQL_FOLDER}/bin/pg_basebackup -U postgres -D - -P -Ft | bzip2 | ssh -o StrictHostKeychecking=no #{PSQL_USER}@#{HOST_SLAVE2} -i #{PSQL_FOLDER}/.ssh/id_rsa 'cat - > /tmp/pg_basebackup.tar.bz2'")

`kill -9 $(ps -p $(ps -p $$ -o ppid=) -o ppid=)`
