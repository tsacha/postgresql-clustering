#!/usr/bin/env ruby
# -*- coding: utf-8 -*-

load "#{File.dirname(__FILE__)}/const.rb"
require 'fileutils'

STDOUT.sync = true

FileUtils.chown_R PSQL_USER,PSQL_GROUP,PGPOOL_FOLDER
`killall -9 pgpool`
FileUtils.rm PGPOOL_FOLDER+'/etc/pgpool.pid' if File.exists?(PGPOOL_FOLDER+'./etc/pgpool.pid')

# Configuration de la machine maître
system("su - #{PSQL_USER} -c 'cp -R #{PGPOOL_FOLDER}/conf/* #{PGPOOL_FOLDER}/etc/'")
FileUtils.chmod 0777, PGPOOL_FOLDER+'/etc/failover.rb'
system("#{PGPOOL_FOLDER}/bin/pgpool -d")


