#!/usr/bin/env ruby
# -*- coding: utf-8 -*-

load "#{File.dirname(__FILE__)}/const.rb"
require 'net/http'
require 'fileutils'

STDOUT.sync = true


# Téléchargement, configuration et installation de PostgreSQL

puts "Création du répertoire initial de PostgreSQL…"


FileUtils.mkdir_p(PSQL_FOLDER+"/conf") if not FileTest.directory?(PSQL_FOLDER)
FileUtils.mkdir_p(PSQL_FOLDER+"/src") if not FileTest.directory?(PSQL_FOLDER+"/src")
if `hostname`.strip == HOST_SLAVE
  FileUtils.mkdir_p(PSQL_FOLDER+'/'+HOST_MASTER) if not FileTest.directory?(PSQL_FOLDER+'/'+HOST_MASTER)
end

puts "Gestion des permissions…"
`groupadd #{PSQL_GROUP} 2> /dev/null`
`useradd -d #{PSQL_FOLDER} -g #{PSQL_GROUP} #{PSQL_USER} 2> /dev/null`
FileUtils.mkdir_p(PSQL_FOLDER+"/.ssh") if not FileTest.directory?(PSQL_FOLDER+"/.ssh")
FileUtils.chown_R PSQL_USER,PSQL_GROUP,PSQL_FOLDER

puts "Téléchargement des sources de PosgreSQL…"
Net::HTTP.start(PSQL_URI) do |http|
    begin
      file = open(PSQL_FOLDER+'/src/'+PSQL_ARCHIVE, 'wb')
      http.request_get('/' + URI.encode(PSQL_URI_GET)) do |response|
      response.read_body do |segment|
        file.write(segment)
        end
    end
    ensure
      file.close
    end
end

puts "Décompression des sources…"
Dir.chdir(PSQL_FOLDER+"/src")
`tar xjf #{PSQL_ARCHIVE} --strip-components 1`

puts "Pré-requis pour la compilation…"
system("yum -y install make gcc readline-devel zlib-devel")
system("./configure --prefix='#{PSQL_FOLDER}'")

puts "Compilation…"
system("make")
system("make install")
