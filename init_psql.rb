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

puts "Téléchargement des sources de PostgreSQL…"
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

if `hostname`.strip == HOST_PGPOOL
  FileUtils.mkdir_p(PGPOOL_FOLDER+"/src") if not FileTest.directory?(PGPOOL_FOLDER+"/src")
  FileUtils.mkdir_p(PGPOOL_FOLDER+"/conf") if not FileTest.directory?(PGPOOL_FOLDER+"/conf")

  FileUtils.chown_R PSQL_USER,PSQL_GROUP,PGPOOL_FOLDER

  puts "Téléchargement des sources de pgPool…"
  Net::HTTP.start(PGPOOL_URI) do |http|
    begin
      file = open(PGPOOL_FOLDER+'/src/'+PGPOOL_ARCHIVE, 'wb')
      http.request_get('/' + URI.encode(PGPOOL_URI_GET)) do |response|
        response.read_body do |segment|
          file.write(segment)
        end
      end
    ensure
      file.close
    end
  end

  puts "Décompression des sources…"
  Dir.chdir(PGPOOL_FOLDER+"/src")
  `tar xzf #{PGPOOL_ARCHIVE} --strip-components 1`
  
  puts "Pré-requis pour la compilation…"
  system("./configure --with-pgsql-includedir=#{PSQL_FOLDER}/include/ --with-pgsql-libdir=#{PSQL_FOLDER}/lib/ --prefix=#{PGPOOL_FOLDER}"
)
  puts "Compilation…"
  system("make")
  system("make install")
end
