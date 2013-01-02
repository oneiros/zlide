require 'spec_helper'
require 'rack/test'

describe Zlide::Server::Base do
  include Rack::Test::Methods

  def app
    Zlide::Server::Base
  end

  describe 'GET /' do

    it "should serve a deck's html" do
      html = "<h1>Test</h1>"
      Zlide::Deck.any_instance.should_receive(:to_html).and_return(html)
      get '/'
      last_response.should be_ok
      last_response.body.should == html
    end

  end

end
