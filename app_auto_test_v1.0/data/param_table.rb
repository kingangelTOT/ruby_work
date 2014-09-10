#encoding:utf-8
require 'data/element'
# require 'data/init_test_data'
# require 'common/log'
class ParamTable < MyElement
    include MyLog
    attr_accessor :param_table
    def initialize(control_value)
        super
        @param_table = []
        @param_table = pf.parse_param_table('param_table') if project_array.size > 0
    end

    def load_param_by_table
        self.pf.load_param_data(self.param_table)
    end
end