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

Dir.chdir("./data")
`tar xvjf /tmp/pg_basebackup.tar.bz2`

FileUtils.chown_R PSQL_USER,PSQL_GROUP, PSQL_FOLDER
system("su - #{PSQL_USER} -c 'cp -R #{PSQL_FOLDER}/conf/* #{PSQL_FOLDER}/data/'")

