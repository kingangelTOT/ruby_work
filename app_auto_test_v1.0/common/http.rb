#encoding:UTF-8
require 'net/http'
require 'base64' 
require 'cgi'
require 'uri'
require 'common/log'
#require File.expand_path("../log.rb", __FILE__)
# load "log.rb"
module Http
	include MyLog
	def http_get(host,path,param,name)
		# begin
		# uri = URI(URI.encode(host+path+param))
		url = URI.parse(URI.encode(host+path+param))
		# resp = nil
		resp = Net::HTTP.get_response(url)
		if Net::HTTPSuccess === resp
			# puts "response = #{resp.body}"
			logger(name).info "interface: "+host+path
			logger(name).info "requestData: "+param
			logger(name).info "response: "+resp.body
			logger(name).info "code: "+resp.code+",message:"+resp.message+",className:"+resp.class.name
			resp.body
		else
			logger(name).error "response: "+resp.body
			logger(name).error "code: "+resp.code+",message:"+resp.message+",className:"+resp.class.name
		end
		# rescue Exception
		#   logger(name).error "/base/http.rb:http_get,程序内部异常"
		# end
		# response.body	
	end

	def http_post(hostName,path,param,name)
		begin
		# puts "param = #{param}"
		#   param = YAML::load(File.open(File.expand_path("../../config/host.yml", __FILE__)))
			uri = URI(hostName)
			data = param
			# puts data
			http = Net::HTTP.new(uri.host, uri.port)
			path = path
			headers = {
				'Content-Type'=>'application/x-www-form-urlencoded'
			}
			resp = http.post(path, data, headers)
			logger(name).error "interface:#{hostName}#{path}返回值为空" if resp.nil?
			if !resp.code.eql?("200")
				logger(name).error "code:#{resp.code}"
				logger(name).error "请求异常再次请求***开始******************"
				http_post(hostName,path,param,name) 
			else
				if Net::HTTPSuccess === resp
					# puts "response = #{resp.body}"
					logger(name).info "interface: "+hostName+path
					logger(name).info "requestData: "+data
					logger(name).info "response: "+resp.body
					logger(name).info "code: "+resp.code+",message:"+resp.message+",className:"+resp.class.name
          resp.body
				else
					logger(name).error "interface: "+hostName+path
					logger(name).error "requestData: "+data
					logger(name).error "response: "+resp.body
					logger(name).error "code: "+resp.code+",message:"+resp.message+",className:"+resp.class.name
				end
			end
			
		rescue Exception
			logger(name).error "请求超时"
			logger(name).error "请求异常再次请求***开始******************"
			sleep(5)
			http_post(hostName,path,param,name)
    end
	end

	def http_put(hostName,path,param)

	end
	def http_delete(hostName,path,param)

	end

	def URLEncode(str)
		str.gsub!(/[^\w$&\-+.,\/:;=?@]/) { |x| x = format("%%%x", x[0]) }
	end
end

# require 'json'
# include Http
# for i in 0..1000
# 	res = http_get("http://hao.17173.com","/gift-tao-19291.html","?_=1398248850057","get_number")
# 	hash = JSON.parse(res)
# 	hash["cardInfo"]["card_number"]
# 	res2 = http_get("http://passport.kongzhong.com","/v/activecode/check","?clientid=actcodetxt&rand=1398248412427&actcode=#{hash["cardInfo"]["card_number"]}&_=1398248411160","check_number")
# 	puts res2
# 	sleep(1)
# end
# puts URI.escape("RwoIMjRm9aJkH/yvGrOXwvARoBzpkaFqD6PQpAygIjj6I2nMpbF4cnl2GvVESn4GLFxou9Vks9fQKVBl0Qp/BFcIOBJz0Z+nZSAXmE3DW0VmmT4sCfLtr29Acxhji1Quhr5xj4g6jMonS92lR3I61isBc4VIkiB8QoYCLX3iBCg=")