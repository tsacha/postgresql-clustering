#!/usr/bin/env ruby
# -*- coding: utf-8 -*-

load "#{File.dirname(__FILE__)}/const.rb"
require 'fileutils'

STDOUT.sync = true

FileUtils.rm_r(PSQL_FOLDER) if FileTest.directory?(PSQL_FOLDER)
FileUtils.rm_r(PGPOOL_FOLDER) if FileTest.directory?(PGPOOL_FOLDER)
#FileUtils.rm_r(INSTALL_FOLDER) if FileTest.directory?(INSTALL_FOLDER)
system("userdel #{PSQL_USER} 2> /dev/null")
system("groupdel #{PSQL_GROUP} 2> /dev/null")
