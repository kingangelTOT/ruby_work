#encoding:utf-8
require 'driver/driver_element'
require 'driver/driver_param_table'
require 'script/val_class'
require 'common/log'

class DriverFlow
    include MyLog
    attr_accessor :val_class, :control_value, :project_name
    def initialize(data_sources, control_value)
        @project_name = control_value['project']
        @data_sources = data_sources
        @control_value = control_value
        @de = DriverElement.new(data_sources, control_value)
        @dpt = DriverParamTable.new(data_sources)
        # @val_class = ValClass.new(control_value)
    end

    # def post_param_to_others
    #     post_param_to_param
    #     post_param_to_element
    # end

    def begin_flow(flow, mwd)
        # puts "@control_value:#{@control_value}"
        element_report_array = Array.new
        # post_param_to_others
        # puts flow.eql?(@control_value['begin_flow'])
        mwd.start_web_page if flow.eql?(@control_value['begin_flow']) && control_value['app_or_web'].eql?('web')

        specific_flow = @data_sources.flow_hash[flow]
        specific_flow.each {|element|
            logger(project_name).info "***#{flow}****element******begin:#{element}************************"
            element_report_hash = @de.begin_element(element, mwd, flow)
            logger(project_name).info "***#{flow}*****element*****end:#{element}************************\n"
            element_report_array << element_report_hash
            if element_report_hash
                break if element_report_hash['element_result'].eql?('no_element_break') || element_report_hash['element_result'].eql?('empty')
            end

            hash = @dpt.trigger_cycle(element, flow)
            # puts hash
            logger(project_name).info "元素 #{element} 是否触发触发参数化:#{!hash.empty?}"
            if !hash.empty?
                retry_elements = hash['retry_elements']
                if hash.has_key?('need_element')
                    need_elements = hash['need_element']
                    logger(project_name).info "此元素参数化所需要的元素:#{need_elements}"
                end                
                param_source = param_source(hash)
                logger(project_name).info "参数化所需要获得的数据#{param_source}"
                param_source.each {|element_content|
                    logger(project_name).info "index:#{element_content['index']};此次参数化所需要获得的数据:#{element_content}"
                    retry_elements.each {|retry_element_one|
                        need_element_content = nil
                        if !need_elements.nil?
                            if need_elements.has_key?(retry_element_one)
                                need_elements[retry_element_one].each{|need_element|
                                    need_element_content = element_content[need_element] if element_content.has_key?(need_element)
                                }
                            end
                        end
                        logger(project_name).info "***#{flow}****element******begin:#{retry_element_one}*****content_index:#{element_content['index']}******正在循环中*************"
                        logger(project_name).info "运行参数化数据所需要的元素:#{retry_elements}"
                        element_report_hash = @de.begin_element(retry_element_one, mwd, element_content, need_element_content, flow)
                        logger(project_name).info "***#{flow}*****element*****end:#{retry_element_one}*******content_index:#{element_content['index']}******正在循环中***********\n"
                        # raise "流程:#{flow},重复的元素不在流程表中!!!!" if !specific_flow.include?(retry_element_one)
                        logger(project_name).info "从#{specific_flow}中删除元素:#{retry_element_one}"
                        specific_flow.delete(retry_element_one) if element != retry_element_one
                        element_report_array << element_report_hash 
                        logger(project_name).info "flow:#{flow};element:#{retry_element_one};index:#{element_content['index']};element_report_array:#{element_report_array}"
                        if element_report_hash
                            break if element_report_hash['element_result'].eql?('no_element_break') || element_report_hash['element_result'].eql?('empty')
                        end
                    }
                    mwd.analysis_driver("#{hash['driver_operate_type']}") if hash.has_key?('driver_operate_type')
                }
            end
            # logger(project_name).info "specific_flow:#{specific_flow}"
            # next if !hash.empty?
        }
        element_report_array.delete(false)
        element_report_array
    end

    def param_source(hash)
        case hash['param_source']
            when 'param'
                param_data = @data_sources.load_param_by_table[hash['param_source_value']]
            when 'script'
                # puts "get_element:#{@de.transmit_value[hash['need_element']]}"
                param_data = @val_class.send :"#{hash['param_source_value']}",:value_from_element => @de.transmit_value[hash['need_element']],:retry_elements => hash['retry_elements']
            else
                raise '参数化不支持此类型!!!!'
        end
        param_data
    end

    def get_param_fom_transmitr
        @de.transmit_value
    end
end
