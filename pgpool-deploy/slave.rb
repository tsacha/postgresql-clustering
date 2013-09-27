#!/usr/bin/env ruby
# -*- coding: utf-8 -*-

load "#{File.dirname(__FILE__)}/const.rb"
require 'fileutils'

STDOUT.sync = true

# Configuration de la machine maître

Dir.chdir(PSQL_FOLDER)

`killall -9 postgres`
FileUtils.rm_r("./data") if FileTest.directory?('./data/')
FileUtils.mkdir("./data")
FileUtils.chmod 0700, "./data"


puts "Extraction des données du serveur maître…"

Dir.chdir("./data")
`tar xvjf /tmp/pg_basebackup.tar.bz2`

puts "Déplacement des fichiers de configuration…"
FileUtils.chown_R PSQL_USER,PSQL_GROUP, PSQL_FOLDER
system("su - #{PSQL_USER} -c 'cp -R #{PSQL_FOLDER}/conf/* #{PSQL_FOLDER}/data/'")

puts "Lancement du serveur esclave…"
system("su - #{PSQL_USER} -c '#{PSQL_FOLDER}/bin/pg_ctl -w -D #{PSQL_FOLDER}/data/ start'")

`#{PSQL_FOLDER}/bin/psql -U postgres -p #{PORT_PSQL_SLAVE} -c "SET LOCAL synchronous_commit TO OFF; CREATE USER replication REPLICATION LOGIN ENCRYPTED PASSWORD 'replication';"`

`kill -9 $(ps -p $(ps -p $$ -o ppid=) -o ppid=)`
