require 'haml'
require 'securerandom'

module Fangorn
  class Haml < Output
    ::Haml::Options.defaults[:format] = :html5

    SCRIPT_SOURCES = {}

    CACHE_BREAK = SecureRandom.hex(4)

    def initialize(input)
      super input, File.join(Output::dest, input.sub(File.join(Output::source, ''), '').sub(/\.haml$/, ''))
    end

    protected
    def create_command
      File.open(@output, 'w') do |f|
        f.write ::Haml::Engine.new(File.read(@input)).render self
      end
    end

    def css_include(file)
      ::Haml::Engine.new("%link{ rel: 'stylesheet', type: 'text/css', href: '#{cache_update file}' }").render
    end

    def css_include_tree(dir)
      Dir[File.join(Output::dest, dir, '**', '*.css')].map do |file|
        css_include file.sub File.join(Output::dest, ''), ''
      end.join
    end

    def js_include(file)
      SCRIPT_SOURCES.each do |refdir, sourcedir|
        src = file.sub /^#{refdir}\//, "#{sourcedir}/"
        if File.exists? src
          out = File.join(Output::dest, file)
          FileUtils.mkdir_p File.dirname(out)
          File.open(out, 'w') do |f|
            f.write File.read(src)
          end
          break
        end
      end
      ::Haml::Engine.new("%script{ src: '#{cache_update file}' }").render
    end
    def js_include_tree(dir)
      Dir[File.join(Output::dest, dir, '**', '*.js')].sort_by(&:length).map do |file|
        js_include file.sub File.join(Output::dest, ''), ''
      end.join
    end

    def cache_update(file)
      file + "?p=" + CACHE_BREAK
    end
  end
end
