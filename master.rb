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


FileUtils.rm_r("./.ssh") if FileTest.directory?('./.ssh/')


`su - #{PSQL_USER} -c 'ssh-keygen -f ~/.ssh/id_rsa -N ""'`
