require 'spec_helper'
require 'selenium-webdriver'

describe 'index.html' do
	before do
		Encoding.default_external='utf-8'
		@webserver=start_http()
    @webdriver = Selenium::WebDriver.for :firefox
	end

  it "Http get should be successfull." do
    @webdriver.navigate.to "http://127.0.0.1:10080/index.html"
    expect(@webdriver.title).to eq "rbenv for Windows test page"
  end

	after do
    @webdriver.quit
		@webserver.shutdown
	end

end
