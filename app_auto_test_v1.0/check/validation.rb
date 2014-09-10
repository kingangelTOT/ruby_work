#encoding:utf-8
require 'check/database'
require 'common/base'

class Validation
    include MyBase
    attr_accessor :value
    def initialize(control_value)
        @value = load_config('../../properties/connect.yaml')
    end

    def get_username
        value = load_config('../../properties/auto_control.yaml')
        value['username']
    end
    
    def init_select_database(database_name)
        mysql = MysqlC.new(value, database_name)
        mysql
    end
end
