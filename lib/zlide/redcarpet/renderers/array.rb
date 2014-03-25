# encoding: utf-8

module Zlide
  module Redcarpet
    module Renderers

      class Array < ::Redcarpet::Render::Base

        class ListData < ::Array ; end
        class TableData < ::Array ; end

        attr_reader :slides

        def initialize
          super
          @slides = []
          @list_items = []
          @table_cells = []
          @table_rows = []
          @table_cache = []
        end

        def header(text, level, anchor)
          @current_slide << {type: :headline, text: text, level: level}
          ""
        end

        def list(content, type)
          number_of_items = content.count('.')
          items = @list_items.pop(number_of_items)
          items.each do |item|
            @current_slide.delete(item) if item.is_a? Hash
          end
          index = @table_cache.size
          list = {
            type: :"#{type}_list",
            items: items
          }
          @current_slide << list
          @table_cache << list
          "__table_#{index}"
        end

        def list_item(text, type)
          table = nil
          matches = text.scan(/\n__table_\d+/)
          if matches.any?
            table_marker = matches.first
            table = @table_cache[table_marker.sub("\n__table_", '').to_i]
            text.sub!(table_marker, '')
          end
          @list_items << text
          @list_items << table if table
          table ? ".." : "."
        end

        def table(header, body)
          @current_slide << {
            type: :table,
            body_rows: @table_rows.pop(body.count('.')),
            header_rows: @table_rows.pop(header.count('.'))
          }
          ""
        end

        def table_row(content)
          @table_rows << @table_cells.pop(content.count('.'))
          "."
        end

        def table_cell(content, alignment)
          @table_cells << content
          "."
        end

        def emphasis(text)
          tag :i, text
        end

        def double_emphasis(text)
          tag :b, text
        end

        def strikethrough(text)
          tag :strikethrough, text
        end

        def link(href, title, content)
          "<link href='#{href}'>#{content}</link>"
        end

        def image(href, title, alt_text)
          @current_slide << {type: :image, href: href}
          ""
        end

        def paragraph(text)
          if text =~ /^!SLIDE/
            if @current_slide
              @slides << @current_slide
            end
            @current_slide = []
          else
            @current_slide << {type: :paragraph, text: text}
          end
          ""
        end

        def block_code(code, language)
          @current_slide << {type: :code, code: code, language: language}
          ""
        end

        def doc_footer
          @slides << @current_slide
          ""
        end

        private

        def tag(type, content)
          "<#{type}>#{content}</#{type}>"
        end
      end

    end
  end
end
