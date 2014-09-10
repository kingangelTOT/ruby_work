#encoding:utf-8
require 'data/test_case'

class Flow < MyTestCase
    attr_accessor :flow_hash
    def initialize(control_value)
        super
        # @flowParam_hash = match_hash(hash_to_array(case_hash), pf.parse_flow_param_sheet)
        # puts "#{pf.parse_case_flow_sheet('flows').keys}%%%%%%%%%%%%%%%%%"
        # puts "#{hash_to_array(case_hash)}&&&&&&&&&&&&&&&&&&&&&&&&"
        val_miss_data(hash_to_array(case_hash), pf.parse_case_flow_sheet('flows').keys)
        @flow_hash = match_hash(hash_to_array(case_hash), pf.parse_case_flow_sheet('flows'))
    end
end
# fl = Flow.new
# puts fl.flow_hash