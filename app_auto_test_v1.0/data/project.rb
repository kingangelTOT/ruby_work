#encoding:utf-8
require 'data/parse_file'
require 'common/base'

class Project
    include MyBase
    attr_accessor :project_array, :pf
    def initialize(control_value)
        @pf = ParseFile.new(control_value)
        @project_array = run_case_array(@pf.parse_project_sheet)
    end

    def run_case_array(project_hash)
        array = Array.new
        project_hash.each{|key, value|
            array << key if value
        }
        array
    end
end