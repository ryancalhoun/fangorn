require 'sass'

module Fangorn
  class Sass < Output
    @@cleaned = false

    def initialize(input)
      output = Output::dist? ? application_css : File.join(Output::dest, input.sub(File.join(Output::source, ''), '')).sub(/sass$/, 'css')
      super input, output
    end

    protected
    def create_command
      remove! unless @@cleaned
      @@cleaned = true

      File.open(@output, Output::dist? ? 'a' : 'w') do |f|
        f.puts "/* #{@input} */"
        f.write ::Sass::Engine.new(File.read(@input)).render
        f.puts
      end
    end
    def application_css
      File.join Output::dest, 'stylesheets', 'application.css'
    end
  end
end
