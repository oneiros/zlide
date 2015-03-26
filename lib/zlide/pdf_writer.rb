# encoding: utf-8
require 'prawn'
require 'prawn/measurement_extensions'

module Zlide
  class PDFWriter

    def initialize(slides)
      @slides = slides
      @pdf = Prawn::Document.new(
        :page_size => "A4",
        :page_layout => :landscape,
        :info => {:Title => CONFIG['title']}
      )
      @pdf.define_grid(:rows => 2, :columns => 2, :gutter => 1.cm)
      default_font = @pdf.font.name
      @header_font = default_font
      @body_font = default_font
      read_fonts_from_config
    end

    def write_file
      render
      @pdf.render_file("#{CONFIG['title']}.pdf")
    end

    private

    def headline(element)
      text = element[:text]
      level = element[:level]
      text_size = 17 - level
      @pdf.font @header_font
      @pdf.text text, :size => text_size, :style => :bold, :inline_format => true
      @pdf.font @body_font
      if level <= 2
        @pdf.line_width 0.5
        @pdf.horizontal_rule
        @pdf.stroke
      end
      @pdf.move_down text_size
    end

    def title_page(element)
      text = element[:text]
      level = element[:level]
      @pdf.font @header_font
      @pdf.text text, size: 22, style: :bold, inline_format: true, align: :center, valign: :center
      @pdf.font @body_font
    end

    def list_data(items, type)
      counter = 0
      items.map do |item|
        if item.is_a? String
          case type
          when :unordered_list
            ["•", item]
          when :ordered_list
            counter += 1
            ["#{counter}.", item]
          end
        else
          [nil, list_data(item[:items], item[:type])]
        end
      end
    end

    def list(items, type)
      cell_style = {:borders => [], :padding => 2}
      data = list_data(items, type).map do |row|
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
    end

    def unordered_list(element)
      list(element[:items], :unordered_list)
    end

    def ordered_list(element)
      list(element[:items], :ordered_list)
    end

    def table(element)
      data = []
      body_rows = element[:body_rows]
      header_rows = element[:header_rows]
      data.concat header_rows.map{|row| row.map{|column| "<b>#{column}</b>"}}
      data.concat body_rows
      @pdf.table c, :cell_style => {:inline_format => true, :border_width => 0.5}
      @pdf.move_down 5
    end

    def image(element)
      @pdf.image File.join('public', element[:href]), :fit => [@pdf.bounds.width, @pdf.cursor - 5]
    end

    def paragraph(element)
      @pdf.text(element[:text], :inline_format => true)
    end

    def code(element)
      code = element[:code]
      code.gsub!(/^([ \t]+)/) { |m| "\xC2\xA0" * m.size }
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

    def render
      current_row = 0
      current_column = 0
      @slides.each do |slide|
        current_box = @pdf.grid(current_row, current_column)
        current_box.bounding_box do
          @pdf.line_width 0.25
          @pdf.stroke_bounds
          @pdf.bounding_box([5,@pdf.bounds.top - 5], :width => @pdf.bounds.width - 10, :height => @pdf.bounds.height - 10) do
            if slide.size == 1 and slide.first[:type] == :headline
              title_page(slide.first)
            else
              slide.each do |element|
                send(element[:type], element)
              end
            end
          end
        end
        if current_row == 1 and current_column == 1 and slide != @slides.last
          @pdf.start_new_page
          current_row = 0
          current_column = 0
        else
          current_column += 1
          if current_column > 1
            current_row += 1
            current_column = 0
          end
        end
      end
    end

    def read_fonts_from_config
      ['header_font', 'body_font'].each do |font_setting|
        if font_file = CONFIG[font_setting]
          font_path = "fonts/#{font_file}"
          if File.exist?(font_path)
            family_name = File.basename(font_file, File.extname(font_file))
            @pdf.font_families.update(
              family_name => {normal: font_path, bold: font_path}
            )
            instance_variable_set(:"@#{font_setting}", family_name)
          else
            STDERR.puts "Could not find font file: #{font_path}"
          end
        end
      end
    end
  end
end
