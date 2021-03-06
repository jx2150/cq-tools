require 'rubygems'
require 'json'
require_relative 'cq_common'
require_relative 'cq_configuration'

module CqTools
  module ConfigurationSetter

    def self.list_options(array_with_ids)
      array_with_ids.each_with_index do |entry, i|
        puts "  #{i}: #{entry['id']}"
      end
    end

    def self.select(key_single, default_option)
      puts "Please select #{key_single} to use [#{default_option}]:"
      selected = STDIN.gets
      if selected.nil?
        selected = default_option
      else
        selected = selected.to_i
      end
      selected
    end

    def self.switch(key_single, key_multi, things, default_option)
      puts "Available #{key_multi}:"
      list_options(things)
      selected = select(key_single, default_option)
      while selected < 0 or selected > (things.length - 1)
        puts "Invalid selection please select: (0 - #{things.length - 1})"
        selected = select(key_single, 0)
      end
      selected
    end

    def self.write_env(env_key, val)
      puts "#{env_key}=#{val} "
      file_reader = File.open(Common::env_file, 'rb')
      contents = file_reader.read
      file_reader.close
      contents.gsub!(/^export #{env_key}=.*$/, "export #{env_key}=#{val}")
      file_writer = File.open(Common::env_file, 'wb')
      file_writer.write(contents)
      file_writer.close
    end

    def self.reload_env
      `#{Common::env_file}`
    end

    def self.exec_switch(key_single, key_multi)
      config = Configuration::read_config
      things = config[key_multi]

      # TODO not sure of the best way to initialize if this is the first run ... disable this for now

      # if things.length == 1
      #   puts "Only one #{key_single} available - nothing to switch to"
      #   puts "To add a new #{key_single} configuration modify: #{usr_file}"
      #   exit 0
      # end

      default_option = config[key_single]
      selected = switch(key_single, key_multi, things, default_option)
      config[key_single] = selected
      Configuration::save_config config
      yield config[key_multi][selected] if block_given?
    end
    
  end
end