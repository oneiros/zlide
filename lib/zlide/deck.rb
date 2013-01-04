require 'haml'
require 'yaml'

module Zlide
  
  class Deck

    def initialize
      files = Dir.glob('slides/*.md')
      @slides = Array.new
      files.sort.each do |f|
        slides = File.read(f).split(/(^!SLIDE.*$)/)[1..-1].each_slice(2).map(&:join)
        slides.each do |slide|
          @slides << {:file => f, :content => slide}
        end
      end
    end

    def slide(index)
      @slides[index][:content]
    end

    def update_slide(index, content)
      @slides[index][:content] = content
      file = @slides[index][:file]
      file_slides = @slides.select{|s| s[:file] == file}.map{|s| s[:content]}
      File.open("#{file}.tmp", "w") {|f| f.write(file_slides.join)}
      File.rename("#{file}.tmp", file)
    end

    def to_html
      slides = markdown_parser(Zlide::Redcarpet::Renderers::HTML).render(full_markdown)
      layout = File.read(File.join(File.dirname(__FILE__), "layouts", "deckjs.haml"))
      layout_renderer = Haml::Engine.new(layout)
      layout_renderer.render { slides }
    end

    def to_pdf
      pdf = Zlide::Redcarpet::Renderers::PDF.new
      markdown_parser(pdf).render(full_markdown)
      pdf.write_file
    end

    private

    def full_markdown
      @slides.map{|s| s[:content]}.join
    end

    def markdown_parser(renderer)
      ::Redcarpet::Markdown.new(renderer, :fenced_code_blocks => true, :tables => true)
    end

  end

end
