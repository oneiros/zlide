require 'haml'
require 'yaml'

module Zlide
  
  class Deck

    def initialize
      files = Dir.glob('slides/*.md')
      @markdown = files.sort.map{|f| File.read(f)}.join
    end

    def to_html
      slides = markdown_parser(Zlide::Redcarpet::Renderers::HTML).render(@markdown)
      layout = File.read(File.join(File.dirname(__FILE__), "layouts", "deckjs.haml"))
      layout_renderer = Haml::Engine.new(layout)
      layout_renderer.render { slides }
    end

    def to_pdf
      pdf = Zlide::Redcarpet::Renderers::PDF.new
      markdown_parser(pdf).render(@markdown)
      pdf.write_file
    end

    private

    def markdown_parser(renderer)
      ::Redcarpet::Markdown.new(renderer, :fenced_code_blocks => true, :tables => true)
    end

  end

end
