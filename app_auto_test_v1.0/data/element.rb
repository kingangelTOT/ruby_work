#encoding:utf-8
require 'data/check_point'

class MyElement < CheckPoint
    attr_accessor :element_hash
    def initialize(control_value)
        super
        val_miss_data(hash_to_array(flow_hash), pf.parse_elements_sheet.keys)
        @element_hash = pf.parse_elements_sheet
    end
end
# me = MyElement.new
# puts me.element_hash