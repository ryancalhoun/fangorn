require 'fileutils'

module Fangorn
  class StaticFile < Output
    def initialize(input)
      output = File.join(Output::dest, input.sub(File.join(Output::source, ''), ''))
      super input, output
    end

    protected
    def create_command
      FileUtils.cp @input, @output
    end
  end
end
