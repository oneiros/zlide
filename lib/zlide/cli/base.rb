require 'thor'

module Zlide
  module CLI
    class Base < Thor
      include Thor::Actions

      def self.source_root
        File.expand_path("../../templates", __FILE__)
      end

      desc "new", "create a new slide deck"
      def new(name)
        empty_directory(name)
        self.destination_root = name
        ["slides", "public", "stylesheets", "config"].each do |subdirectory|
          empty_directory(subdirectory)
        end
        @name = name
        template "config/deck.yml.tt"
        template "README.md.tt"
        copy_file "stylesheets/deck-theme.css"
        copy_file "stylesheets/highlight-theme.css"
        copy_file "stylesheets/slides.css"
      end

      desc "serve", "serve your slides via http"
      def serve
        Zlide::Server::Base.run! 
      end

      desc "pdf", "create a pdf version of your slides"
      def pdf
        deck = Zlide::Deck.new
        deck.to_pdf
      end

    end
  end
end
