#encoding:utf-8
require 'data/flow_params'

class DriverFlowParam
    attr_accessor :driver_flowParam_hash
    def initialize(control_value)
        fp = FlowParam.new(control_value)
        @driver_flowParam_hash = fp.flowParam_hash
    end

    def parse_element_data

    end
end
