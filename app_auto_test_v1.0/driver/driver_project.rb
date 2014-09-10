#encoding:utf-8
# $LOAD_PATH << '../'
# $LOAD_PATH << './../'
# puts $LOAD_PATH
require 'data/param_table'
require 'data/init_test_data'
require 'driver/driver_case'
require 'common/base'
require 'yaml'
require 'common/log'

class DriverProject
    include MyLog
    include MyBase
    include InitTestData
    attr_accessor :pt, :project_name, :auto_control
    def initialize(auto_control, package_name)
        @auto_control = auto_control
        @project_name = auto_control['project']
        @package_name = package_name
        @pt = ParamTable.new(auto_control)
        pt.pf.excel_quit
        logger(project_name).info '*******************开始初始化测试数据*******************'
        init_param_data(auto_control, pt.param_table)
        logger(project_name).info "*******************初始化测试数据结束*******************\n"
        @pt = ParamTable.new(auto_control)
        puts pt.project_array
        puts pt.case_hash
        puts pt.flow_hash
        @dc = DriverCase.new(@pt, auto_control)
    end

    # def post_param_to_case
    #     self.dc.receive_param_from_project(args={:data_sources => pt, :auto_control => auto_control})
    # end

    def begin_project
        begin
        # post_param_to_case
            case_report_hash = Hash.new
            pt.project_array.each{|case_value|
                mwd = MyWebDriver.new(:auto_control => auto_control,
                               :package_name => @package_name)
                logger(project_name).info "*******case******begin:#{case_value}************************"
                flow_report_hash = @dc.begin_case(case_value, mwd)
                case_report_hash[case_value] = flow_report_hash
                logger(project_name).info "********case*****end:#{case_value}************************\n"
            }
        ensure
            pt.pf.excel_quit
        end
        # move_excel_to_old(auto_control)
        file_path = is_create_excel(auto_control)
        puts "case_report_hash:#{case_report_hash}"
        add_data_to_sheet(file_path, case_report_hash)
        # pt.pf.excel_quit
        # add_data_to_sheet('test_report/romdu_front/romdu_front1407488523.xlsx', case_report_hash)
    end
end
# def load_config(path)
#     # logger(@name).info "加载文件：路径：#{path}；文件名：#{fileName}"
#     value = YAML::load(File.open(File.expand_path(path, __FILE__)))
#     value
# end
# auto_control = load_config('../../properties/auto_control.yaml')
# DriverProject.new(auto_control).begin_project
