#!/usr/bin/env ruby
# application takes subcommands
# ls for listing clients
# ls number or client name for list of servers
# optparse-positional-arguments.rb
require 'optparse'
require 'rubygems'
require 'json'
require 'pp'

module Sht
  class App
    attr_accessor :options, :config, :projects

    def initialize
      @options = {}
      @config = {}
      @projects = []
      self.parse_options
      self.parse_config_file
      self.json_to_hosts
    end

    def << project
      @projects << project
    end

    def parse_options
      OptionParser.new do |opts|
        opts.banner = "Usage: [options] [command] "

        opts.on("-j", "--json", "See JSON output") do |v|
          @options[:json] = true
        end

        opts.on("-j", "--json", "See JSON output") do |v|
          @options[:json] = true
        end

        opts.on("-c file", "--config file", String, "Use an alternative config file") do |file|
          @options[:config] = file
        end

        opts.on("--list x,y,z", Array, "Just a list of arguments") do |list|
          @options[:list] = list
        end

        opts.on("-p --project", Array, "Show hosts from a given project") do |list|
          @options[:project] = list
        end
      end.parse!
    end

    def parse_config_file
      config_path = @options[:config] ? @options[:config] :  File.expand_path('~/.shuttle.json')
      config_file = File.new(config_path, 'r')
      config_json = config_file.read
      @config = JSON.parse(config_json)
    end

    #todo make this thing work
    def write_config_file
    end
    
    def json_to_hosts
      project_id = 1
      @config['hosts'].each do |project|
        project.each do |host|
          project_name = host[0]
          new_project = Project.new(project_name, [], project_id)

          host_id = 1
          host[1].each do |server|
            new_host = Host.new(server['cmd'], server['name'], host_id)
            host_id += 1
            new_project << new_host
          end
          @projects << new_project
        end
        project_id += 1
      end
    end

    def read_command
      case ARGV[0]
      when 'ls'
        if @options[:project]
          print_project(@options[:project])
        else
          print_projects
        end

      end
    end

    def print_project(id)
      @projects.each do |project|
        if project.id === id[0].to_i
          puts "#{project.id}. #{project.name}"
          project.print_hosts
        end
      end
    end

    def print_projects
      @projects.each do |project|
        puts "#{project.id}. #{project.name}"
        project.print_hosts
      end
    end

  end

  #Project has multiple hosts
  class Project
    attr_reader :name, :hosts, :id

    def initialize name, hosts, id
      @hosts = hosts
      @name = name
      @id = id
    end

    def << host
      @hosts << host
    end

    def print_hosts
      @hosts.each do |host|
        puts "  #{host.id}. #{host.desc} - #{host.cmd}"
      end
    end
  end

  #Hosts have a name and command, should be able to 'go to' one
  class Host
    attr_reader :desc, :cmd, :id
    def initialize desc, cmd, id
      @desc = desc
      @cmd = cmd
      @id = id
    end

    # Fork a process, executing the command needed
    def ssh_to
      system('')
    end
  end
end


app = Sht::App.new
app.read_command
#pp app.config
