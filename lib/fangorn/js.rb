module Fangorn
  class Js < Output
    APPLICATION_JS = File.join Output::dest, 'js', 'application.js'
    @@cleaned = false

    def initialize(input)
      output = Output::dist? ? APPLICATION_JS : File.join(Output::dest?, input.sub(File.join(Output::source, ''), ''))
      super input, output
    end

    protected
    def create_command
      remove! unless @@cleaned
      @@cleaned = true

      File.open(@output, Output::dist? ? 'a' : 'w') do |f|
        f.puts "// #{@input}" if Output::dist?
        f.write File.read(@input) 
        f.puts if Output::dist?
      end
    end
  end
end
