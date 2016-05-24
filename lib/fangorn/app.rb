require 'listen'
require 'optparse'
require 'webrick'

require_relative 'output'

module Fangorn
  class App
    def run
      options = OptionParser.new do |opts|
        opts.on('-s', '--serve', 'Watch source files for change, and serve compiled results') do
          @serve = true
        end
        opts.on('-Jsrc=dest', 'Add javascript vendor directory') do |arg|
          if m = /^(.*?)\/?=(.*?)\/?$/.match(arg)
            Haml::SCRIPT_SOURCES[m[1]] = m[2]
          end
        end
      end

      begin
        options.parse! ARGV
      rescue OptionParser::ParseError => e
        STDERR.puts e
        puts options
        exit 1
      end

      if @serve
        puts "Watching #{Output::source}"
        listener = Listen.to(Output::source, :filter => /\.(haml|sass|js|ico)$/, &update)
        listener.start

        puts 'Starting server on port 8080'
        server = WEBrick::HTTPServer.new Port: 8080
        server.mount '/', NoCacheFileHandler, Output::dest
        trap('INT') { server.stop }
        server.start
      else
        puts "Updating #{Output::source}"
        update[Dir[File.join(Output::source, '**/*.{haml,sass,js,ico}')], [], []]
      end
    end
    def report(type, input, output)
      puts <<-eos
      #{File.extname(output.to_s).upcase} #{type} @ #{Time.now.strftime("%F %T")}:
      - from: #{input}
      - to: #{output}
      eos
    end

    def update
      ->(modified, added, removed) do
        unless added.select {|m| m =~ /\.(js|sass)$/}.empty?
          modified += Dir[File.join(Output::source, '**/*.haml')]
        end

        ordered(modified + added).each do |input|
          if output = Output.make(input)
            output.create!
            report 'generated', input, output
          end
        end

        ordered(removed).each do |input|
          if output = Output.make(input)
            output.remove!
            report 'removed', input, output
          end
        end
      end
    end


    def of_type(type)
      ->(f) { File.extname(f) == type }
    end

    def ordered(files)
      files = files.sort_by(&:length)

      sass = files.select &of_type('.sass')
      js = files.select &of_type('.js')
      haml = files.select &of_type('.haml')

      (sass + js + haml + files).uniq
    end
  end
  class NoCacheFileHandler < WEBrick::HTTPServlet::FileHandler
    def do_GET(req, res)
      super
      res['Cache-Control'] = 'no-cache'
    end
  end

end


