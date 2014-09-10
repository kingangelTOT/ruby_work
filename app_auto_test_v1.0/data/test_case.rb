#encoding:utf-8
require 'data/project'

class MyTestCase < Project
    attr_accessor :case_hash
    def initialize(control_value)
        super
        # puts "#{project_array}@@@@@@@@@@@@@@@@@@"
        # puts "#{pf.parse_case_flow_sheet('test cases')}!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
        @case_hash = match_hash(project_array, pf.parse_case_flow_sheet('test cases'))
    end
end

# tc = MyTestCase.new
# puts tc.case_hash