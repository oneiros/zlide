require "sinatra/base"
require "sprockets"

module Zlide
  module Server

    class Base < Sinatra::Base

      set :assets, Sprockets::Environment.new

      settings.assets.append_path File.join(File.dirname(__FILE__), '..', '..', '..', 'vendor', 'javascripts')
      settings.assets.append_path File.join(File.dirname(__FILE__), '..', '..', '..', 'vendor', 'stylesheets')
      settings.assets.append_path File.join(Dir.pwd, 'stylesheets')

      get '/' do
        Zlide::Deck.new.to_html 
      end

      get '/javascripts/:file.js' do
        content_type 'application/javascript'
        settings.assets["#{params[:file]}.js"]
      end

      get '/stylesheets/:file.css' do
        content_type 'text/css'
        settings.assets["#{params[:file]}.css"]
      end

    end

  end
end
