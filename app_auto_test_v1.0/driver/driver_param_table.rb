#encoding:utf-8

class DriverParamTable
    attr_accessor :data_sources
    def initialize(data_sources)
        @data_sources = data_sources
    end

    def get_driver_param_table
        self.data_sources.param_table
    end

    def get_param_by_table
        self.data_sources.load_param_by_table
    end

    def trigger_cycle(element, flow)
        hash = Hash.new
        # puts "get_driver_param_table:#{get_driver_param_table}**************************"
        get_driver_param_table.each { |value|
            # puts "重复循环的元素:#{value['retry_elements']},是否包含:#{element}"
            # puts "判断结果:#{value['retry_elements'].include?(element)}"
            if value['cir_tag'].include?(element) && value['flow'].eql?(flow)
                hash['retry_elements'] = value['retry_elements']
                hash['param_source'] = value['param_source']
                hash['param_source_value'] = value['param_source_value']
                hash['need_element'] = value['need_element'] if value.has_key?('need_element')
                hash['driver_operate_type'] = value['driver_operate_type'] if value.has_key?('driver_operate_type')
                hash['delete_element'] = value['delete_element'] if value.has_key?('delete_element')
                break
            end
        }
        hash
    end

    # def receive_param_from_flow(args)
    #     self.args = args
    # end
end