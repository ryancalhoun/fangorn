require 'yaml'
require 'securerandom'
module Fangorn
  class Js < Output

    CACHE_BREAK = SecureRandom.hex(4)
    @@cleaned = false

    def initialize(input)
      output = Output::dist? ? application_js : File.join(Output::dest, input.sub(File.join(Output::source, ''), ''))
      super input, output

      @config = YAML.load_file 'fangorn.yml'
    end

    protected
    def create_command
      remove! unless @@cleaned
      @@cleaned = true

      File.open(@output, Output::dist? ? 'a' : 'w') do |f|
        f.puts "// #{@input}" if Output::dist?

        contents = File.read(@input) 
        if config = get_config
          config.each do |key,val|
            contents.gsub!("${#{key}}", val.to_s)
          end
        end
        contents.gsub!(/(templateUrl:\s*["'])([^'"]+)(['"])/, "\\1\\2?q=#{CACHE_BREAK}\\3")

        if Output::dist?
          open("| uglifyjs", 'w+') do |uglifyjs|
            uglifyjs.write contents
            uglifyjs.close_write
            f.puts uglifyjs.read
          end

        else
          f.write contents
        end

      end
    end
    def application_js
      File.join Output::dest, 'js', 'application.js'
    end

    def get_config
      if @config
        @config[Output::env]
      end
    end
  end
end
