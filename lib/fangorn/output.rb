require 'fileutils'

module Fangorn
  class Output
    def initialize(input, output)
      @input, @output = input, output
    end
    def create!
      FileUtils.mkdir_p File.dirname(@output)
      create_command
    end
    def remove!
      FileUtils.rm_f @output
    end
    def to_s
      @output
    end
    def self.make(input)
      type = File.extname(input)[1..-1]
      begin
        Fangorn.const_get(type.capitalize).new input
      rescue LoadError, NameError
        StaticFile.new input
      end
    end

    def self.dist?
      @@dist
    end

    def self.env
      @@env
    end

    def self.source
      File.absolute_path(@@source)
    end
  
    def self.dest
      File.absolute_path(@@dest || (@@dist ? 'dist' : 'public'))
    end

    def self.dist!
      @@dist = true
    end

    def self.source= (source)
      @@source = source
    end
  
    def self.dest= (dest)
      @@dest = dest
    end

    def self.env= (env)
      @@env = env
    end

    @@dist = false
    @@source = 'app'
    @@dest = nil
    @@env = 'default'
  end
end

require_relative 'haml'
require_relative 'sass'
require_relative 'js'
require_relative 'static_file'
