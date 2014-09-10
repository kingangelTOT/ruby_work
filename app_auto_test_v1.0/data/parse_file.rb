#encoding:utf-8

require 'win32ole'
require 'yaml'
require 'json'

class ParseFile
    attr_accessor :flow_max_size
    def initialize(control_value)
        @control_value = control_value
        # noinspection SpellCheckingInspection
        WIN32OLE.codepage = WIN32OLE::CP_UTF8
        @excel = WIN32OLE::new('excel.Application')
        @workbook = @excel.Workbooks.Open("#{@control_value['base_path']}/properties/#{@control_value['project']}.xls")
        @flow_max_size = ['b','c','d','e','f','g','h','i','j','k','l','m','n']
    end

    def parse_project_sheet
        hash = Hash.new
        worksheet = load_sheet(@control_value['project'])
        line = 2
        while data = worksheet.Range("a#{line}:b#{line}").value
            break if data[0][0].nil?
            hash[data[0][0]] = data[0][1]
            line += 1
        end
        hash
    end

    def parse_case_flow_sheet(sheet_name)
        hash = Hash.new
        worksheet = load_sheet(sheet_name)
        line = 2
        # puts flow_max_size
        while data_line = worksheet.Range("a#{line}").value
            break if data_line.nil?
            array = Array.new
            flow_max_size.each { |letter|
                data_row = worksheet.Range("#{letter}#{line}").value
                # puts "#{letter}#{line}"
                # puts data_row
                break if data_row.nil?
                array << data_row
            }
            hash[data_line] = array
            line += 1
        end
        hash
    end

    def parse_check_point_sheet(sheet_name)
        hash = Hash.new
        worksheet = load_sheet(sheet_name)
        line = 2
        while data_line = worksheet.Range("a#{line}").value
            break if data_line.nil?
            data_hash = Hash.new
            array = Array.new
            flow_max_size.each { |letter|
                data_row = worksheet.Range("#{letter}#{line}").value
                break if worksheet.Range("#{letter}1").value.nil?
                data_hash['flow_name'] = data_row if letter.eql?('a')
                data_hash['index'] = data_row if letter.eql?('b')
                data_hash['checkpoint_name'] = data_row if letter.eql?('c')
                data_hash['val_type'] = data_row if letter.eql?('d')
                data_hash['val_element_name'] = data_row if letter.eql?('e')
                data_hash['value_type'] = data_row if letter.eql?('f')
                data_hash['script_name'] = data_row.split(',') if !data_row.nil? && letter.eql?('g')
                data_hash['expectation_type'] = data_row if letter.eql?('h') && !data_row.nil?
                data_hash['expectation_value_or_script'] = data_row.split(',') if letter.eql?('i') && !data_row.nil?
                data_hash['need_script_param'] = data_row.split(',') if letter.eql?('j') && !data_row.nil?
                # data_hash['param_index'] = data_row if letter.eql?('k') && !data_row.nil?
            }

            if hash.has_key?(data_line)
                hash[data_line] << data_hash
            else
                array << data_hash
                hash[data_line] = array
            end
            line += 1
        end
        hash
    end

    def parse_param_table(sheet_name)
        array = Array.new
        worksheet = load_sheet(sheet_name)
        line = 2
        array_index = flow_max_size
        array_index.insert(0, 'a')
        while data_line = worksheet.Range("a#{line}").value
            break if data_line.nil?
            hash = Hash.new
            array_index.each { |letter|
                data_row = worksheet.Range("#{letter}#{line}").value
                break if worksheet.Range("#{letter}1").value.nil?
                hash['parametric_element'] = data_row.split(',') if letter.eql?('a')
                hash['param_source'] = data_row if letter.eql?('b')
                hash['param_source_value'] = data_row if letter.eql?('c')
                hash['need_element'] = JSON.parse(data_row) if letter.eql?('d') && !data_row.nil?
                # puts "data_row:#{data_row}"
                hash['retry_elements'] = data_row.split(',') if letter.eql?('e')
                hash['flow'] = data_row if letter.eql?('f')
                hash['driver_operate_type'] = data_row if letter.eql?('g') && !data_row.nil?
                hash['delete_element'] = data_row.split(',') if letter.eql?('h') && !data_row.nil?
            }
            array << hash
            line += 1
        end
        array
    end

    def load_param_data(array)
        hash = Hash.new
        if array.size > 0
            array.each {|value|
                if value['param_source'].eql?('param')
                    worksheet = load_sheet(value['param_source_value'])
                    array = Array.new
                    array_index = flow_max_size
                    # array_index.insert(0, 'a')
                    line = 2
                    while data_line = worksheet.Range("a#{line}").value
                        break if data_line.nil?
                        param_hash = Hash.new
                        array_index.each { |letter|
                            break if worksheet.Range("#{letter}1").value.nil?
                            data_row = worksheet.Range("#{letter}#{line}").value
                            param_hash["#{worksheet.Range("#{letter}1").value}"] = data_row if !data_row.nil?
                        }
                        array << param_hash
                        line += 1
                    end
                    hash["#{value['param_source_value']}"] = array
                end
            }
        end
        hash
    end

    # def parse_flow_param_sheet
    #     hash = Hash.new
    #     worksheet = load_sheet(5)
    #     line = 2
    #     while data_line = worksheet.Range("a#{line}").value
    #         break if data_line.nil?
    #         array = Array.new
    #         @control_value['flow_max_size'].each { |letter|
    #             data_row = worksheet.Range("#{letter}#{line}").value
    #             break if data_row.nil?
    #             array = JSON.parse(data_row)
    #         }
    #         hash[data_line] = array
    #         line += 1
    #     end
    #     hash
    # end

    def parse_elements_sheet
        hash = Hash.new
        worksheet = load_sheet('elements')
        line = 2
        while data_line = worksheet.Range("a#{line}").value
            break if data_line.nil?
            hash_element_property = Hash.new
            flow_max_size.each { |letter|
                data_row = worksheet.Range("#{letter}#{line}").value
                # puts "#{letter}:#{data_row}"
                break if worksheet.Range("#{letter}1").value.nil?
                hash_element_property['element_location'] = JSON.parse(data_row) if letter.eql?('b')
                if letter.eql?('c')
                    if data_row
                        hash_element_property['is_operate'] = JSON.parse(data_row)
                    else
                        hash_element_property['is_operate'] = data_row
                    end
                end
                # hash_element_property['is_check'] = data_row if letter.eql?('d')
                if letter.eql?('d')
                    if data_row
                        hash_element_property['is_operate_driver'] = JSON.parse(data_row)
                    else
                        hash_element_property['is_operate_driver'] = data_row
                    end
                end
                # hash_element_property['need_transmit'] = data_row if letter.eql?('e')
                hash_element_property['transmit_type'] = data_row if letter.eql?('e') && !data_row.nil?
                hash_element_property['get_element_name'] = data_row if letter.eql?('f') && !data_row.nil?
                # hash_element_property['get_element_name'] = data_row.split(',') if letter.eql?('h') && hash_element_property['is_get_element'].eql?('yes')
                hash[data_line] = hash_element_property
            }
            line += 1
        end
        hash
    end

    def excel_quit
        @workbook.close
        @excel.Quit
        system('taskkill /f /im EXCEL.EXE ')
        system('taskkill /f /im et.exe ')
    end

    def load_sheet(sheet_name)
        worksheet = nil
        @workbook.Worksheets.each{|sheet_value|
            if sheet_value.name == sheet_name
                worksheet = sheet_value
                break
            end
        }

        # worksheet.Select
        worksheet
    end 
end

# pf = ParseFile.new
#
# puts pf.parse_elements_sheet
# pf.excel_quit