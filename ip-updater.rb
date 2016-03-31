#!/usr/bin/env ruby

require 'rubygems'
require 'commander/import'

program :version, '0.0.1'
program :description, 'Update Google Spreadsheet with system local IP address'

command :list, do |c|
  c.syntax = 'ip-updater list, [options]'
  c.summary = ''
  c.description = ''
  c.example 'description', 'command example'
  c.option '--some-switch', 'Some switch that does something'
  c.action do |args, options|
    # Do something or c.when_called Ip-updater::Commands::List,
  end
end

command :update, do |c|
  c.syntax = 'ip-updater update, [options]'
  c.summary = ''
  c.description = ''
  c.example 'description', 'command example'
  c.option '--some-switch', 'Some switch that does something'
  c.action do |args, options|
    # Do something or c.when_called Ip-updater::Commands::Update,
  end
end

