#!/usr/bin/env ruby
# -*- coding: utf-8 -*-

load "#{File.dirname(__FILE__)}/const.rb"

STDOUT.sync = true

Dir.chdir(PSQL_FOLDER)
system("su - #{PSQL_USER} -c '#{PSQL_FOLDER}/bin/pg_ctl -D #{PSQL_FOLDER}/data/ start > logfile 2>&1 &'")
