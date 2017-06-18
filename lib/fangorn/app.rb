require 'listen'
require 'optparse'
require 'webrick'

require_relative 'output'

module Fangorn
  class App
    def initialize
      @port = 8080
    end
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
        opts.on('-d', '--dist', 'Compile a distribution package') do
          Output::dist!
        end
        opts.on('-D', '--dest=DIR', 'dest dir') do |dir|
          Output::dest = dir
        end
        opts.on('-e', '--env=ENV', 'Use environment name with fangorn.yml settings') do |env|
          Output::env = env
        end
        opts.on('-p', '--port=PORT', /^\d+$/, 'Serve on port [8080]') do |port|
          @port = port.to_i
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
        listener = Listen.to(Output::source, :filter => /\.(haml|sass|js|ico|jpg|png|ttf)$/, &update)
        listener.start

        puts "Starting server on port #{@port}"
        server = WEBrick::HTTPServer.new Port: @port
        server.mount '/', NoCacheFileHandler, Output::dest
        trap('INT') { server.stop }
        server.start
      else
        puts "Updating #{Output::source}"
        update[Dir[File.join(Output::source, '**/*.{haml,sass,js,ico,jpg,png,ttf}')], [], []]
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

        mixins, modified = modified.partition {|m| File.basename(m) =~ /^_.+.sass$/}
        puts "MIXINS #{mixins}"
        unless mixins.empty?
          modified += Dir[File.join(Output::source, '**/[^_]*.sass')]
        end

        ordered(modified + added).each do |input|
          if output = Output.make(input)
            begin
              output.create!
              report 'generated', input, output
            rescue => e
              puts e
            end
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


