#encoding:utf-8
require 'script/val_class'
require 'common/log'

module InitTestData
    include MyLog
    def need_param_table(param_table_array)
        array = Array.new
        param_table_array.each{|param_table_value|
            array << param_table_value['param_source_value']
        }
        array
    end
    
    def init_param_data(control_value, param_table_array)
        param_array = need_param_table(param_table_array)
        param_array.each{|param_name|
            logger(control_value['project']).info "*******************初始化数据表: #{param_name} 开始*******************"
            init_add_data_to_sheet(control_value, param_name)
            logger(control_value['project']).info "*******************初始化数据表: #{param_name} 结束*******************"
        }
    end
    
    def init_add_data_to_sheet(control_value, param_name)
        excel = WIN32OLE.new('Excel.Application')
        excel.visible = true
        workbook = excel.Workbooks.Open("#{control_value['base_path']}/properties/game_center.xls")
        worksheet = workbook.Worksheets(param_name)
        val = ValClass.new(control_value)
        val.send :"#{control_value['init_test_data'][param_name]}", worksheet, control_value
        workbook.Save
        excel.ActiveWorkbook.Close(0)
        # workbook.close
        excel.Quit()
    end
end