require 'yaml'
module Fangorn
  class Js < Output
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

        f.write contents
        f.puts if Output::dist?
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
