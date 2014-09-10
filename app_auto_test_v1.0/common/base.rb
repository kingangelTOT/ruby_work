#encoding:UTF-8
$LOAD_PATH << '../'
require 'yaml'
require 'net/smtp'
require 'common/log'
# require 'spreadsheet'
require 'fileutils'
require 'win32ole'
# include RSpec::Expectations

module MyBase
    include MyLog
    # noinspection RubyResolve
    def load_config(path)
        # logger(@name).info "加载文件：路径：#{path}；文件名：#{fileName}"
        value = YAML::load(File.open(File.expand_path(path, __FILE__)))
        value
    end

    def match_hash(base_array, target_hash)
        target_hash.each_key { |k|
            target_hash.delete(k) if !base_array.include?(k)
        }
        target_hash
    end

    def hash_to_array(hash)
        array = []
        hash.each_value {|v|
            v.each{|av|
                array.push(av) if !array.include?(av)
            }
        }
        array
    end

    def val_miss_data(base_array, target_array)
        raise "缺失数据: #{target_array} 对比 #{base_array}" if base_array.size > target_array.size
        if base_array.size == target_array.size
            raise "数据名称错误: #{target_array} 对比 #{base_array}" if !base_array.sort.join.eql?(target_array.sort.join)
        elsif base_array.size < target_array.size
            target_array.delete_if{|x|
                !base_array.include?(x)
            }
            raise "数据名称错误: #{target_array} 对比 #{base_array}" if !base_array.sort.join.eql?(target_array.sort.join)
        end
    end

    def is_create_excel(control_value)
        project_name = control_value['project']
        today = Time.now.to_i
        path = "#{control_value['app_path']}/log"
        Dir.mkdir(path) if !File.directory?(path)
        # Spreadsheet.client_encoding = 'UTF-8'
        # book = Spreadsheet::Workbook.new
        # sheet = book.create_worksheet :name => project_name
        # book.write "#{path}/#{project_name}#{today}.xls"
        WIN32OLE.codepage = WIN32OLE::CP_UTF8
        WIN32OLE.codepage = 65001
        excel = WIN32OLE.new('Excel.Application')
        excel.visible = true
        workbook = excel.Workbooks.Add()
        workbook.saveas("#{path}/#{project_name}#{today}.xlsx")
        excel.ActiveWorkbook.Close(0)
        excel.Quit()
        "#{path}/#{project_name}#{today}.xlsx"
    end

    def move_excel_to_old(control_value)
        project_name = control_value['project']
        path = "test_report/#{project_name}/old"
        Dir.mkdir(path) if !File.directory?(path)
        Dir.foreach("test_report/#{project_name}").each {|file|
            if file.include?'.xlsx'
                FileUtils.mv Dir.glob("test_report/#{project_name}/#{project_name}*.xlsx"), "test_report/#{project_name}/old"
            end
        }
    end

    def add_data_to_sheet(file_name, case_report_hash)
        excel = WIN32OLE.new('Excel.Application')
        excel.visible = true
        workbook = excel.Workbooks.Open(file_name)
        worksheet = workbook.Worksheets(1)
        worksheet.Range('A1:G1').value = %w( 检查点名称 元素名称 元素测试结果 期望结果 结果 流程名称 案例名称 )
        array = Array.new
        case_report_hash.keys.each{|case_name|
            case_hash = case_report_hash[case_name]
            case_hash.keys.each{|flow_name|
                case_hash[flow_name].each{|element_report_value|
                    element_content = Array.new
                    element_content << element_report_value['checkpoint_name']
                    element_content << element_report_value['element_index']
                    element_content << element_report_value['element_result']
                    element_content << element_report_value['expect_result']
                    element_content << element_report_value['compare_result']
                    element_content << flow_name
                    element_content << case_name
                    array << element_content
                }
            }
        }
        i = 2
        array.each { |value|
            worksheet.Range("A#{i}:G#{i}").value = value
            i+=1
        }
        workbook.Save
        excel.ActiveWorkbook.Close(0)
        excel.Quit()
    end

    def send_email(subject,content,to=nil)
        from = 'kai.yan@tsingch.com'
        to = ['kingangela.258@163.com'] if to.nil?
        sendmessage = 'Subject: '+subject +"\n\n"+content
        smtp = Net::SMTP.start('smtp.exmail.qq.com',25,'kai.yan@tsingch.com',
                               'kai.yan@tsingch.com',
                               'king258angel', :login)
        smtp.send_message sendmessage,from,to
        smtp.finish
    end
    
    def capture_stdout
        stdout = $stdout.dup
        Tempfile.open 'stdout-redirect' do |temp|
            $stdout.reopen temp.path, 'w+'
            yield if block_given?
            $stdout.reopen stdout
            temp.read
        end
    end
end