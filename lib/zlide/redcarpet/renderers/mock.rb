module Zlide
  module Redcarpet
    module Renderers

      class Mock < ::Redcarpet::Render::HTML #Base

        def block_html(text)
          puts "block html: #{text}"
        end

        def paragraph(text)
          if text =~ /!SLIDE/
            puts "p: #{text}"
          else
            puts super(text)
          end
        end

        def header(text, level)
          puts "header#{level}: #{text}"
        end

        def entity(text)
          puts "ENTITY: #{text}"
        end

      end

    end
  end
end
