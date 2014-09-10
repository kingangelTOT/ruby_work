#encoding:utf-8
$LOAD_PATH << '../'
require 'mysql2'
# require 'common/log'
# require 'common/base'
# require 'net/ssh/Gateway'

class MysqlC
    attr_accessor :dbc, :connect_value
    def initialize(value, database_name)

        @connect_value = value
        # puts select_mysql_type
        # start_mysql_by_ssh
        # port = start_mysql_by_ssh
        # puts port
        puts "connect_value:#{value}"
        puts "database_name:#{database_name}"
        @dbc = Mysql2::Client.new(
                host: connect_value['alpha_host'],
                username: connect_value['alpha_userName'],
                password: connect_value['alpha_password'],
                database: database_name,
                port: connect_value['alpha_port']
        )
        @dbc.query('SET NAMES utf8')
    end

    def select_mysql_type
        port = @connect_value['alpha_port']
        port = start_mysql_by_ssh if @connect_value['mysql_type'].eql?('ssh')
        port
    end

    def start_mysql_by_ssh
        gateway = Net::SSH::Gateway.new(
                @connect_value['ssh_host'],
                @connect_value['ssh_username'],
                :password => @connect_value['ssh_password']
        )
        puts 'true' if gateway.active?
        port = gateway.open(@connect_value['alpha_host'], @connect_value['alpha_port'], 3310)
        port
    end

    def get_from_sql(sql)
        dbc.query(sql)
    end

    def get_value_from_query_to_array(res, index)
        array = Array.new
        res.each {|row|
            array << row[index]
        }
        array
    end

    def close_mysql
        @dbc.close
    end
end
# mqc = MysqlC.new
