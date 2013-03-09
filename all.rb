#!/usr/bin/env ruby
# -*- coding: utf-8 -*-

load 'const.rb'
require 'optparse'
require 'fileutils'

options = {:verbose => false, :install => true, :remote => true, :master => true, :slave => true, :pgpool => true, :reset => false}
OptionParser.new do |opts|
  opts.banner = "Usage: all.rb [options]"

  opts.on("-v", "--verbose", "Run verbosely") do |v|
    options[:verbose] = v
  end

  opts.on("-i", "--[no-]install", "Install PostgreSQL") do |i|
    options[:install] = i
  end

  opts.on("-r", "--[no-]remote", "Send remote scripts and install Ruby on remote servers") do |r|
    options[:remote] = r
  end

  opts.on("-m", "--[no-]master", "Prepare master server") do |m|
    options[:master] = m
  end

  opts.on("-s", "--[no-]slave", "Prepare slave server") do |s|
    options[:slave] = s
  end

  opts.on("-p", "--[no-]pgpool", "Prepare pgpool server") do |p|
    options[:pgpool] = p
  end

  opts.on("--reset", "Reset all remove servers") do |reset|
    options[:reset] = reset
  end

end.parse!

puts
puts "------"
puts "Exécution du script d'installation de PosgreSQL"
puts "------"
puts

if options[:reset]
  puts "Réinitialisation des serveurs…"

  if options[:master]
    master = Thread.new() {
      if options[:remote]
        puts "Envoi du script de réinitialisation…"
        `scp -P #{PORT_SSH_MASTER} reset.rb #{HOST_MASTER}:/tmp`
        
        puts "Envoi des constantes…"
        `scp -P #{PORT_SSH_MASTER} const.rb #{HOST_MASTER}:/tmp`
      end

      puts "Réinitialisation du serveur maître…"
      system("ssh #{HOST_MASTER} -p #{PORT_SSH_MASTER} ruby /tmp/reset.rb")
    }
  end

  if options[:slave]
    slave = Thread.new() {
      if options[:remote]
        puts "Envoi du script de réinitialisation…"
        `scp -P #{PORT_SSH_SLAVE} reset.rb #{HOST_SLAVE}:/tmp`

        puts "Envoi des constantes…"
        `scp -P #{PORT_SSH_SLAVE} const.rb #{HOST_SLAVE}:/tmp`
      end

      puts "Réinitialisation du serveur esclave…"
      system("ssh #{HOST_SLAVE} -p #{PORT_SSH_SLAVE} ruby /tmp/reset.rb")
    }
  end

  if options[:pgpool]
    pgpool = Thread.new() {
      if options[:remote]
        puts "Envoi du script de réinitialisation…"
        `scp -P #{PORT_SSH_PGPOOL} reset.rb #{HOST_PGPOOL}:/tmp`

        puts "Envoi des constantes…"
        `scp -P #{PORT_SSH_PGPOOL} const.rb #{HOST_PGPOOL}:/tmp`
      end

      puts "Réinitialisation du serveur PgPool…"
      system("ssh #{HOST_PGPOOL} -p #{PORT_SSH_PGPOOL} ruby /tmp/reset.rb")
    }
  end
  
  if options[:master]
    master.join
  end
  
  if options[:slave]
    slave.join
  end
  
  if options[:pgpool]
    pgpool.join
  end

  exit 0
end


if options[:master]
  master = Thread.new() {
    # Installation de la machine maître
    if options[:remote]
      puts "Création du répertoire d'installation…"
      `ssh #{HOST_MASTER} -p #{PORT_SSH_MASTER} mkdir -p #{INSTALL_FOLDER}`
      
      puts "Envoi du script d'installation de PostgreSQL…"
      `scp -P #{PORT_SSH_MASTER} init_psql.rb #{HOST_MASTER}:#{INSTALL_FOLDER}`
      
      puts "Envoi des constantes d'installation…"
    `scp -P #{PORT_SSH_MASTER} const.rb #{HOST_MASTER}:#{INSTALL_FOLDER}`
      
      puts "Envoi du script de configuration du serveur maître…"
      `scp -P #{PORT_SSH_MASTER} master.rb #{HOST_MASTER}:#{INSTALL_FOLDER}`
    
      puts "Installation de Ruby…"
      `ssh #{HOST_MASTER} -p #{PORT_SSH_MASTER} yum -y install ruby`
    end
    
    if options[:install]
      puts "Installation de PostgreSQL…"
      system("ssh #{HOST_MASTER} -p #{PORT_SSH_MASTER} ruby #{INSTALL_FOLDER}/init_psql.rb")
    end

    puts "Configuration du serveur maître…"
    system("ssh #{HOST_MASTER} -p #{PORT_SSH_MASTER} ruby #{INSTALL_FOLDER}/master.rb")

    puts "Réécriture des fichiers de configuration PostgreSQL…"
    FileUtils.cp(INSTALL_FOLDER+'/master/postgresql.conf.template',INSTALL_FOLDER+'/master/postgresql.conf')
    FileUtils.cp(INSTALL_FOLDER+'/master/pg_hba.conf.template',INSTALL_FOLDER+'/master/pg_hba.conf')

    file_names = [INSTALL_FOLDER+'/master/postgresql.conf', INSTALL_FOLDER+'/master/pg_hba.conf']
    
    file_names.each do |file_name|
      replace = File.read(file_name)
      replace = replace.gsub(/HOST_MASTER/, HOST_MASTER)
      replace = replace.gsub(/PORT_PSQL_MASTER/, PORT_PSQL_MASTER)
      replace = replace.gsub(/PORT_SSH_SLAVE/, PORT_SSH_SLAVE)
      replace = replace.gsub(/PSQL_USER/, PSQL_USER)
      replace = replace.gsub(/HOST_SLAVE_IP/, HOST_SLAVE_IP)
      replace = replace.gsub(/HOST_SLAVE/, HOST_SLAVE)
      replace = replace.gsub(/PSQL_FOLDER/, PSQL_FOLDER)
      replace = replace.gsub(/SYNC_MASTER/, SYNC_MASTER)
      File.open(file_name, "w") { |file| file.puts replace }
    end
  }
end


if options[:slave]
  slave = Thread.new() {
    # Installation de la machine esclave
    if options[:remote]
      puts "Création du répertoire d'installation…"
      `ssh #{HOST_SLAVE} -p #{PORT_SSH_SLAVE} mkdir -p #{INSTALL_FOLDER}`
    
      puts "Envoi du script d'installation de PostgreSQL…"
      `scp -P #{PORT_SSH_SLAVE} init_psql.rb #{HOST_SLAVE}:#{INSTALL_FOLDER}`
      
      puts "Envoi des constantes d'installation…"
      `scp -P #{PORT_SSH_SLAVE} const.rb #{HOST_SLAVE}:#{INSTALL_FOLDER}`

      puts "Envoi du script de configuration du serveur secondaire…"
      `scp -P #{PORT_SSH_SLAVE} slave.rb #{HOST_SLAVE}:#{INSTALL_FOLDER}`

      puts "Installation de Ruby…"
      `ssh #{HOST_SLAVE} -p #{PORT_SSH_SLAVE} yum -y install ruby`
    end
    
    if options[:install]
      puts "Installation de PostgreSQL…"
      system("ssh #{HOST_SLAVE} -p #{PORT_SSH_SLAVE} ruby #{INSTALL_FOLDER}/init_psql.rb")
    end

    puts "Configuration du serveur esclave…"
    system("ssh #{HOST_SLAVE} -p #{PORT_SSH_SLAVE} ruby #{INSTALL_FOLDER}/slave.rb")

  }
end

if options[:pgpool]
  pgpool = Thread.new() {
    # Installation de la machine pgpool
    if options[:remote]
      puts "Création du répertoire d'installation…"
      `ssh #{HOST_PGPOOL} -p #{PORT_SSH_PGPOOL} mkdir -p #{INSTALL_FOLDER}`
      
      puts "Envoi du script d'installation de PostgreSQL…"
      `scp -P #{PORT_SSH_PGPOOL} init_psql.rb #{HOST_PGPOOL}:#{INSTALL_FOLDER}`
      
      puts "Envoi des constantes d'installation…"
      `scp -P #{PORT_SSH_PGPOOL} const.rb #{HOST_PGPOOL}:#{INSTALL_FOLDER}`
    
      puts "Installation de Ruby…"
      `ssh #{HOST_PGPOOL} -p #{PORT_SSH_PGPOOL} yum -y install ruby`
    end

    if options[:install]
      puts "Installation de PostgreSQL…"
      system("ssh #{HOST_PGPOOL} -p #{PORT_SSH_PGPOOL} ruby #{INSTALL_FOLDER}/init_psql.rb")
    end
  }
end

if options[:master]
  master.join
end

if options[:slave]
  slave.join
end

if options[:pgpool]
  pgpool.join
end
