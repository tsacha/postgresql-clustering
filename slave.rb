#!/usr/bin/env ruby
# -*- coding: utf-8 -*-

load "#{File.dirname(__FILE__)}/const.rb"
require 'fileutils'

STDOUT.sync = true

# Configuration de la machine maître

Dir.chdir(PSQL_FOLDER)

FileUtils.rm_r("./data") if FileTest.directory?('./data/')
`killall -9 postgres`

# TODO
# Récupération de l'archive
# Décompression

FileUtils.mkdir_p(PSQL_FOLDER+'/'+HOST_MASTER) if not FileTest.directory?(PSQL_FOLDER+'/'+HOST_MASTER)
FileUtils.chown_R 'postgres','postgres', PSQL_FOLDER+'/'+HOST_MASTER
