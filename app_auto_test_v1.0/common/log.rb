#encoding:UTF-8
require 'logger'

module MyLog
  	def logger(name)
    		path = '../log'
        Dir.mkdir(path) if !File.directory?(path)
    		logger = Logger.new(STDERR,"../log/#{name}.log", 'daily') #按天生成
    		logger.level = Logger::INFO
    		logger.formatter = proc { |severity, datetime, progname, msg|
    	    	"#{severity}: #{progname}: #{datetime}: #{msg}\n"
    		}
    		logger
	 end
end