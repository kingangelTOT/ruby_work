#encoding:utf-8
require 'script/val_class'
require 'common/base'
require 'common/log'
require 'driver/web_driver'
require 'driver/driver_check_point'
require 'script/val_class'

class DriverElement
    include MyBase
    include MyLog
    attr_accessor :transmit_value, :project_name, :control_value
    def initialize(data_source, control_value)
        @project_name = control_value['project']
        @transmit_value = Hash.new
        @data_source = data_source
        @control_value = control_value
        @val = ValClass.new(control_value)
        @dcp = DriverCheckPoint.new(data_source, control_value, @val)
    end

    def begin_element(element_index, mwd, content = nil, need_element = nil, flow)
        # post_param_to_web_drivercontent
        # puts "element_index:#{element_index}"
        raise "flow中的元素索引:#{element_index},不在元素列表中!!!...." if !@data_source.element_hash.has_key?(element_index)
        element_content = @data_source.element_hash[element_index]
        element_content_location = element_content['element_location']
        element_content_operate = element_content['is_operate']
        driver_content_operate = element_content['is_operate_driver']
        # element_content_need_transmit = element_content['need_transmit']
        element_content_transmit_type = ''
        element_content_transmit_type = element_content['transmit_type'] if element_content.has_key?('transmit_type')
        # element_content_is_get_element = element_content['is_get_element']
        element_content_get_element_name = element_content['get_element_name'] #功能未实现
        element_report_hash = ''
        if !element_content_location['is_script_condition'].eql?('no_element')
            element = mwd.element_present?(element_content_location['how'], element_content_location['what'], element_content_location['is_script_condition'])
            operate_value = is_operate_element(mwd,element, element_index, element_content_operate, content, need_element)
            # sleep(element_content_operate['is_wait']) if element_content_operate.has_key?('is_wait')
            logger(project_name).info "元素:#{element_index}的操作类型:#{element_content_operate}, 操作值:#{content[element_index]}" if !operate_value.eql?('')
            is_operate_driver(mwd, driver_content_operate) if driver_content_operate
            element_report_hash = @dcp.check_element(element_index, mwd, element, content, flow, transmit_value)
            # puts "element_report_hash:#{element_report_hash}"
            if control_value['app_or_web'].eql?('web')
                mwd.close_alert_and_get_its_text if mwd.alert_present?
            end
            if !element_content_transmit_type.eql?('') && element
                logger(project_name).info "元素:#{element_index},需要传输!!!!!!!"
                if element_content_transmit_type.eql?('operate_value')
                    raise "不做操作的元素:#{element_index},没有操作值可供传输!!!!" if operate_value.empty?
                    logger(project_name).info "元素:#{element_index},传输类型是:操作值"
                    transmit_value[element_index] = operate_value
                else
                    logger(project_name).info "元素:#{element_index},传输类型是:#{element_content_transmit_type}"
                    value = mwd.analysis_element(:element => element, :type => element_content_transmit_type)
                    transmit_value[element_index] = value
                end
            end
        else
            mwd.send :"#{element_content_operate['operate_script']}", mwd
            element_report_hash = false
        end
        logger(project_name).info "transmit_value:#{transmit_value}"
        # logger(@control_value['project']).info "get_element:#{get_element}"
        element_report_hash
    end

    def is_operate_element(mwd, element, element_index, element_content_operate, content, need_element)
        operate_value = ''
        logger(@control_value['project']).info "元素#{element_index},是否需要操作:#{element_content_operate != false}+#{!element_content_operate.eql?('')},element_content_operate:#{element_content_operate}"
        if element_content_operate && !element_content_operate.eql?('') && element
            if element_content_operate['operate_type'].eql?('send_keys') || element_content_operate['operate_type'].eql?('select_list')
                # puts "content:#{content}"
                if !content.nil? && content.has_key?(element_index)
                    # puts "element_index:#{element_index}"
                    content_data = content[element_index] 
                    content_data = @val.send :"#{content_data}", need_element if content_data.include?('script')
                    logger(project_name).info  "content_data:#{content_data}"
                    operate_value = content_data
                end
                mwd.operate_element(element, element_content_operate['operate_type'], operate_value)
            elsif element_content_operate['operate_type'].eql?('click') || element_content_operate['operate_type'].eql?('submit')
                mwd.operate_element(element, element_content_operate['operate_type'])
            else
                raise "#{element_content_operate['operate_type']}:操作类型未识别,请代码中增加新类型或修改成已知类型!!!"
            end
        end
        operate_value
    end

    def is_operate_driver(mwd, driver_content_operate)
        mwd.operate_driver(driver_content_operate['operate_type'], driver_content_operate['content'])
    end

    # def post_param_to_web_driver
    #     @mwd.receive_param_from_element(args)
    # end
    #
    # def receive_param_from_flow(args)
    #     self.args = args
    # end
end