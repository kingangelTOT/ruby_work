#encoding:utf-8
require 'data/flow'

class CheckPoint < Flow
    attr_accessor :check_point
    def initialize(control_value)
        super
        @check_point = pf.parse_check_point_sheet('check_point')
        # puts check_point
    end
end