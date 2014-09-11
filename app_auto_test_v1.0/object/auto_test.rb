#encoding:utf-8
$LOAD_PATH << './../'
require 'yaml'
require 'tempfile'
# require 'chilkat'
require 'common/log'
require 'common/base'
require 'driver/driver_project'

class AutoTest
    include MyBase
    include MyLog
    attr_accessor :auto_control, :dp
    def initialize
        monkey_path = '../../properties/auto_control.yaml'
        @auto_control = load_config(monkey_path)
    end

    def start_monkey
        # begin
            flag = true
            mount = 1
            while flag
                puts mount
                # auto_control['uninstall_apk'].each {|package_name|
                    # uninstall_apk(package_name)
                # }
                apk_info_array = get_apk_info(auto_control['app_path'])
                apk_info_array = [{'package_name'=>'com.tcg.penny'}]
                apk_info_array.each {|apk_info|
                    # raise "#{apk_info['apk_name']}:安装失败,请检查测试手机是否与电脑连接!!!!!" if !install_apk("#{auto_control['app_path']}/#{apk_info['apk_name']}").eql?('Success')
#                     
                    # File.delete("#{auto_control['app_path']}/#{apk_info['apk_name']}")
                    # move_apk_to_old(apk_info['apk_name'])
                    log_path = "#{auto_control['app_path']}/log"
                    Dir.mkdir(log_path) if !File.directory?(log_path)
                    # system("adb shell monkey -p #{apk_info['package_name']} -s #{auto_control['s']} --ignore-crashes --ignore-timeouts --monitor-native-crashes -v -v #{auto_control['touch']} > #{log_path}/#{apk_info['apk_name']}_log.txt")
                    # sleep(auto_control['monkey_time'])
                    # data_hash = parse_moneky_log("#{log_path}/#{apk_info['apk_name']}_log.txt")
                    begin
                        DriverProject.new(auto_control, apk_info['package_name']).begin_project
                    rescue Exception => e
                        logger(auto_control['project']).error e
                        system("adb shell logcat>E:\auto_test\log\#{apk_info['package_name']}_android.txt")
                        retry
                    end
                    
                    # send_email(subject, body)
                    # send_email(subject,content,to=nil)
                    sleep(auto_control['ready_time'])
                }
                mount += 1
            end
        # rescue RuntimeError => e
            # puts "e:#{e}*****************8"
            # puts 'has some wrong'
        # end
    end

    def install_apk(apk_path)
        puts "adb install #{apk_path}"
        captured_content = capture_stdout do
            system("adb install #{apk_path}")
        end
        string_size = captured_content.chop.size
        # puts captured_content.chop[string_size-7,string_size].eql?('Success')
        # puts captured_content.chop[string_size-7,string_size]
        captured_content.chop[string_size-7,string_size]
    end

    def uninstall_apk(package_name)
        captured_content = capture_stdout do
            system("adb uninstall #{package_name}")
        end
        captured_content.chop
    end

    def load_config(path)
        value = YAML::load(File.open(File.expand_path(path, __FILE__)))
        value
    end

    def get_apk_info(path)
        apk_info_array = Array.new
        apk_info_hash = Hash.new
        Dir.foreach(path).each {|file|
            if file.include?'.apk'
                captured_content = capture_stdout do
                    system "aapt d badging #{path}/#{file}"
                end
                apk_info_hash['apk_name'] = file
                package_name = parsing_apk_info(captured_content)
                raise "#{file}:安装包的package_name为空,请检测安装包!!!!!" if package_name.eql?('')
                apk_info_hash['package_name'] = package_name
                apk_info_array << apk_info_hash
            end
        }
        apk_info_array
    end

    def parsing_apk_info(apk_info)
        apk_app_name = ''
        if apk_info.include?'package: name='
            begin_index = apk_info.index('package: name=')+15
            end_index = 0
            for i in begin_index..10000
                if apk_info[i].eql?("'")
                    end_index = i-1
                    break
                end
            end
            apk_app_name = apk_info[begin_index..end_index]
        end
        apk_app_name
    end

    def move_apk_to_old(file_name)
        path = "#{auto_control['app_path']}/old"
        Dir.mkdir(path) if !File.directory?(path)
        FileUtils.mv Dir.glob("#{auto_control['app_path']}/#{file_name}"), "#{path}"
    end

    def parse_moneky_log(file_path)
        has_crash = false
        event_num = 0
        num = 0
        crash_array = Array.new
        data_hash = Hash.new
        File.open(file_path,'r') do |file|
            while line = file.gets
                data = line.chop
                event_num += 1 if data.include?':Sending'
                if line.chop.include? 'CRASH'
                    crash_array << event_num
                    has_crash = true
                end
                num+=1
            end
        end
        data_hash['has_crash'] = has_crash
        data_hash['crash_array'] = crash_array
        data_hash
    end
end
puts AutoTest.new.start_monkey
# puts ':AutoTest: seed=100 count=20000'.include?':Sending'