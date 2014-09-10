#encoding:utf-8
require 'driver/driver_flow'
require 'common/log'

class DriverCase
    include MyLog
    attr_accessor :args, :data_sources, :project_name
    def initialize(data_sources, control_value)
        @project_name = control_value['project']
        @data_sources = data_sources
        @control_value = control_value
        @df = DriverFlow.new(data_sources, control_value)
    end

    # def post_param_to_flow
    #     @df.receive_param_from_case(args)
    # end

    def begin_case(case_value, mwd)
       flow_report_hash = Hash.new
        self.data_sources.case_hash[case_value].each { |flow|
            logger(project_name).info "*******flow******begin:#{flow}************************"
            element_report_array = @df.begin_flow(flow, mwd)
            flow_report_hash[flow] = element_report_array
            logger(project_name).info "********flow*****end:#{flow}************************\n"
        }
        flow_report_hash
    end

    # def receive_param_from_project(args)
    #     self.args = args
    # end
end

# dc = DriverCase.new
# dc.begin_case


