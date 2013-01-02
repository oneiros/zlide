module Zlide
  module Redcarpet
    module Renderers

      class HTML < ::Redcarpet::Render::HTML

        def initialize(options = {})
          @slide_open = false
          super(options)
        end

        def paragraph(text)
          result = ""
          if text =~ /^!SLIDE/
            result += "</section>\n" if @slide_open
            result += "<section class=\"slide\">\n"
            @slide_open = true
          else
            result += "<p>#{text}</p>\n"
          end
          result
        end

        def doc_footer
          if @slide_open
            @slide_open = false
            "</section>"
          end
        end

      end

    end
  end
end
