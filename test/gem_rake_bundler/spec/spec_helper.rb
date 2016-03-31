# $LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'bundler/setup'
require 'webrick'

def start_http(opt={})
	s = WEBrick::HTTPServer.new({
		  :DocumentRoot => File.expand_path('../../html', __FILE__),
		  :BindAddress => '127.0.0.1',
		  :Port => 10080,
	    :AccessLog => [[File.open('accesslog.txt', 'w'), WEBrick::AccessLog::CLF]],
		  :Logger => WEBrick::Log.new("log.txt", WEBrick::BasicLog::DEBUG),
		}.merge(opt).merge({:StartCallback => Proc.new{ Thread.main.wakeup }}))
	
	trap("INT"){ s.shutdown }
  @server_thread = Thread.new do
		s.start
  end
  Thread.stop
  s
end

RSpec.configure do |config|
  config.filter_run :debug => true
  config.run_all_when_everything_filtered = true
end
