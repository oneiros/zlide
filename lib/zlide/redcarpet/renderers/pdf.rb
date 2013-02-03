# encoding: utf-8
require 'prawn'
require 'prawn/measurement_extensions'

module Zlide
  module Redcarpet
    module Renderers

      class PDF < ::Redcarpet::Render::Base

        class ListData < ::Array ; end
        class TableData < ::Array ; end

        def initialize
          @pdf = Prawn::Document.new(
            :page_size => "A4", 
            :page_layout => :landscape, 
            :info => {:Title => CONFIG['title']}
          )
          @pdf.define_grid(:rows => 2, :columns => 2, :gutter => 1.cm)
          @current_row = 0
          @current_column = 0
          @command_queue = []
          @current_box = @pdf.grid(0,0)
          @slide_open = false
          @list_items = []
          @table_cells = []
          @table_rows = []
          @table_cache = []
          super
        end

        def header(text, level)
          text_size = 17 - level
          @command_queue << Proc.new do 
            @pdf.text text, :size => text_size, :style => :bold, :inline_format => true
            if level <= 2
              @pdf.line_width 0.5 
              @pdf.horizontal_rule
              @pdf.stroke
            end
            @pdf.move_down text_size
          end
          ""
        end

        def list(content, type)
          data = ListData.new 
          counter = 1
          number_of_items = content.count('.') 
          @list_items.pop(number_of_items).each do |item|
            if item.is_a? String
              case type
              when :unordered
                data << ["•", item]
              when :ordered
                data << ["#{counter}.", item]
                counter += 1
              end
            else
              data << [nil, item]
              @command_queue.delete(item)
            end
          end
          index = @table_cache.size
          @command_queue << data 
          @table_cache << data
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
          data = TableData.new
          body_rows = @table_rows.pop(body.count('.'))
          header_rows = @table_rows.pop(body.count('.'))
          data.concat header_rows.map{|row| row.map{|column| tag(:b, column)}}
          data.concat body_rows
          @command_queue << data
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
          @command_queue << Proc.new do
            @pdf.image File.join('public', href), :fit => [@pdf.bounds.width, @pdf.cursor - 5]
          end
          ""
        end

        def paragraph(text)
          if text =~ /^!SLIDE/
            if @slide_open
              next_box
            else
              @slide_open = true
            end
          else
            @command_queue << Proc.new { @pdf.text(text, :inline_format => true) }
          end
          "" 
        end

        def block_code(code, language)
          code.gsub!(/^(\s+)/m) { |m| "\xC2\xA0" * m.size }
          code_block = Proc.new do
            font = @pdf.font.name
            @pdf.bounding_box([5, @pdf.cursor], :width => @pdf.bounds.width - 10) do
              @pdf.move_down 5
              @pdf.font "Courier"
              @pdf.indent(5) { @pdf.text code, :size => 9 }
              @pdf.line_width 0.1
              @pdf.join_style :round
              @pdf.stroke_bounds
            end
            @pdf.font font
            @pdf.move_down 5
          end
          @command_queue << code_block 
          ""
        end

        def write_file
          @pdf.render_file("#{CONFIG['title']}.pdf")
        end

        private

        def next_box
          @current_box.bounding_box do
            @pdf.line_width 0.5 
            @pdf.stroke_bounds
            @pdf.bounding_box([5,@pdf.bounds.top - 5], :width => @pdf.bounds.width - 10, :height => @pdf.bounds.height - 10) do
              @command_queue.each do |c|
                if c.is_a? Proc
                  c.call
                elsif c.is_a? ListData
                  cell_style = {:borders => [], :padding => 2}
                  data = c.map do |row|
                    row.map do |cell|
                      if cell.is_a? Array
                        @pdf.make_table cell, :cell_style => cell_style.merge(:inline_format => true), :column_widths => [25, @pdf.bounds.width - 55]
                      else
                        cell
                      end
                    end
                  end
                  @pdf.table data, :cell_style => cell_style, :column_widths => [25, @pdf.bounds.width - 30] do |t|
                    t.cells.grep(Prawn::Table::Cell::Text).each {|text| text.style({:inline_format => true})}
                  end
                  @pdf.move_down 5
                elsif c.is_a? TableData
                  @pdf.table c, :cell_style => {:inline_format => true, :border_width => 0.5}
                  @pdf.move_down 5
                end
              end
            end
          end
          @command_queue.clear 
          if @current_row == 1 and @current_column == 1
            @pdf.start_new_page
            @current_row = 0
            @current_column = 0
          else
            @current_column += 1
            if @current_column > 1
              @current_row += 1
              @current_column = 0
            end
          end
          @current_box = @pdf.grid(@current_row, @current_column)
        end

        def tag(type, content)
          "<#{type}>#{content}</#{type}>"
        end
      end

    end
  end
end
