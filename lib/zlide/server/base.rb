require "sinatra/base"
require "sprockets"

module Zlide
  module Server

    class Base < Sinatra::Base

      set :root, Dir.pwd

      set :assets, Sprockets::Environment.new

      settings.assets.append_path File.join(File.dirname(__FILE__), '..', '..', '..', 'vendor', 'javascripts')
      settings.assets.append_path File.join(File.dirname(__FILE__), '..', '..', '..', 'vendor', 'stylesheets')
      settings.assets.append_path File.join(Dir.pwd, 'stylesheets')

      set :deck, Zlide::Deck.new

      get '/' do
        settings.deck.to_html 
      end

      get '/slide/:id' do |id|
        settings.deck.slide(id.to_i)
      end

      post '/slide/:id' do |id|
        settings.deck.update_slide(id.to_i, params[:slide])
        "OK"
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
