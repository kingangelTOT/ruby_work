#encoding:utf-8
require 'common/log'
require 'script/val_class'
require 'common/base'

class DriverCheckPoint
    include MyLog
    include MyBase
    attr_accessor :data_sources, :check_point_data, :project_name, :control_value
    def initialize(data_sources, control_value, val)
        @val = val
        @control_value = control_value
        @project_name = control_value['project']
        @data_sources = data_sources
        @check_point_data = data_sources.check_point
        # @parse_data_hash = parse_data
        # puts "@check_point_data:#{@check_point_data}"
        # puts "parse_data_hash:#{parse_data_hash}"
        # @worksheet = initialize_excel
    end

    # def initialize_excel
    #     excel = WIN32OLE::new('excel.Application')
    #     workbook = excel.Workbooks.Open('c:\examples\spreadsheet.xls')
    #     worksheet = workbook.Worksheets(1) #定位到第一个sheet
    #     worksheet.Select
    #     worksheet
    # end
    def get_check_data(hash_content, check_data)
        hash_content['val_element_name'] = check_data['val_element_name'] if check_data.has_key?('val_element_name')
        hash_content['checkpoint_name'] = check_data['checkpoint_name'] if check_data.has_key?('checkpoint_name')
        hash_content['val_type'] = check_data['val_type'] if check_data.has_key?('val_type')
        hash_content['value_type'] = check_data['value_type'] if check_data.has_key?('value_type')
        hash_content['script_name'] = check_data['script_name'] if check_data.has_key?('script_name')
        hash_content['expectation_type'] = check_data['expectation_type'] if check_data.has_key?('expectation_type')
        hash_content['expectation_value_or_script'] = check_data['expectation_value_or_script'] if check_data.has_key?('expectation_value_or_script')
        hash_content['need_script_param'] = check_data['need_script_param'] if check_data.has_key?('need_script_param')
        hash_content
    end
    
    def find_check_data(flow, content_index, element_index)
        hash_content= Hash.new
        if check_point_data.has_key?(flow)
            array = Array.new
            check_point_data[flow].each{|value|
                array << value if value['val_element_name'].eql?(element_index)
            }
            if array.size > 1 && !content_index.nil?
                check_data = nil
                array.each{|value|
                    check_data = value if value['index'] == content_index
                }
                raise '参数化数据未匹配到检查项!!!!' if check_data.nil?
                hash_content = get_check_data(hash_content, check_data)
            elsif array.size == 1
                check_data = array[0]
                hash_content = get_check_data(hash_content, check_data)
            end
        end
        hash_content
    end

    def check_element(element_index, mwd, element, content, flow, transmit_value)
        content_index = content['index'] if !content.nil?
        content_index = nil if content.nil?
        check_point_specified = Hash.new
        check_point_specified = find_check_data(flow, content_index, element_index)
        logger(project_name).info "check_point_specified:#{check_point_specified}"
        # return 'element is empty' if !element
        return false if check_point_specified.length == 0 || !check_point_specified['val_element_name'].eql?(element_index)
        hash = Hash.new
        
        element_result = select_val_type(check_point_specified, element, check_point_specified['value_type'], mwd, content, transmit_value)
        compare_result = false
        # element_result = element_expect(check_point_specified['expectation_type'], check_point_specified, content, transmit_value) if check_point_specified.has_key?('script_name')
        expect_result = element_expect(check_point_specified['expectation_type'], check_point_specified, content, transmit_value)
        compare_result = true if element_result.to_s.eql?(expect_result.to_s)
        hash['checkpoint_name'] = check_point_specified['checkpoint_name']
        hash['element_index'] = element_index
        hash['element_result'] = element_result
        hash['expect_result'] = expect_result
        hash['compare_result'] = compare_result
        # logger(project_name).info "check_result_index:{flow}=>#{element_index}=>#{content_index}"
        logger(project_name).info "check_result_data:#{hash}"
        hash
    end
    
    def select_val_type(check_point_specified, element, value_type, mwd, content, transmit_value)
        self.send :"#{check_point_specified['val_type']}", element, check_point_specified, mwd, content, transmit_value
    end
        
    def no_element(*args)
        result = nil
        case args[1]['value_type']
            when 'is_empty'
                result = 'empty' if !args[0]
                result = 'exist' if args[0]
            when 'is_alert'
                result = args[2].alert_present?
            when 'alert_text'
                result = args[2].close_alert_and_get_its_text
            when 'script'
                # result = element_expect('script',args[1],args[3],args[4])
                transmit_hash = process(args[1], args[4])
                script_name = args[1]['script_name']
                result = @val.send :"#{script_name[0]}", control_value, args[3], script_name[1..script_name.length-1], transmit_hash, @val
        end
        result
    end
    
    
    def element(*args)
        args[2].analysis_element(:element => args[0], :type => args[1]['value_type'])
    end
    # def check_empty_element(element_index, content)
        # hash = Hash.new
        # element_content = parse_data_hash[element_index]
        # hash['checkpoint_name'] = element_content['checkpoint_name']
        # hash['element_index'] = element_index
        # hash['element_result'] = element_result
        # hash['expect_result'] = expect_result
        # hash['compare_result'] = compare_result
        # hash
    # end
    
    def process(value, transmit_value)
        transmit_hash = Hash.new
        if value.has_key?('need_script_param')
            transmit_hash['transmit_value'] = transmit_value
            transmit_hash['need_script_param'] = value['need_script_param']
        end
        transmit_hash
    end
    
    def element_expect(expectation_type, value, content, transmit_value)
        result = ''
        transmit_hash = process(value, transmit_value)
        
        case expectation_type
            when 'script'
                expectation_value_or_script = value['expectation_value_or_script']
                result = @val.send :"#{expectation_value_or_script[0]}", control_value, content, expectation_value_or_script[1..expectation_value_or_script.length-1], transmit_hash, @val
            when 'sql'
                result = @val.send :val_get_from_sql, value['expectation_value_or_script']
            when 'string'
                expectation_value_or_script = value['expectation_value_or_script']
                result = value['expectation_value_or_script'][0] if "#{expectation_value_or_script.class}".eql?('Array')
        end
        result
    end

    # def element_result(val_type, mwd, element)
        # result = ''
        # case val_type
            # when 'element'
                # result = mwd.analysis_element(:element => element, :type => val_type)
            # when 'driver'
                # result = mwd.analysis_element(:type => value['value_type'])
            # else
                # logger(project_name).info "验证元素类型:#{val_type} 不支持!!!!!!!!"
        # end
        # result
    # end
end