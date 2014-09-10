#encoding:utf-8
require 'selenium-webdriver'
require 'common/log'
require 'common/base'
require 'appium_lib'
require 'script/game_center'

class MyWebDriver
    include MyLog
    include GameCenter
    include MyBase
    attr_accessor :driver, :args
    def initialize(args)
        @args = args
        @driver = select_driver
        @accept_next_alert = true
    end

    def select_driver
        driver = nil
        driver = Selenium::WebDriver.for :"#{args[:auto_control]['web_driver']}" if args[:auto_control]['app_or_web'].eql?('web')
        if args[:auto_control]['app_or_web'].eql?('app')
            caps = {caps:{deviceName: args[:auto_control]['app_driver']['device_name'],
                          platformName: args[:auto_control]['app_driver']['platform_name'],
                          appActivity: args[:auto_control]['app_driver']["#{args[:package_name]}"]['app_activity'],
                          appPackage: args[:auto_control]['app_driver']["#{args[:package_name]}"]['app_package']},
                    appium_lib: {sauce_username: nil, sauce_access_key: nil}}
            driver = Appium::Driver.new(caps).start_driver
        end
        driver
    end

    def start_web_page
        driver.navigate.to(args[:auto_control]['begin_url'])
    end

    def find_element_self(is_script_condition, how, what)
        case is_script_condition
            when 'script'
                element = driver.execute_script(what)
            when 'find_element'
                element = driver.find_element(how, what)
            when 'find_elements'
                element = driver.find_elements(how, what)
            else
                raise "元素查询类型:#{is_script_condition}不支持,请扩展类型或者另选其它类型!!!!"
        end
        element
    end

    def operate_element(element, operate_type, content=nil, transmit_value = nil)
        case operate_type
            when 'send_keys'
                element.clear
                is_hide_keyboard
                element.send :"#{operate_type}", content
                is_hide_keyboard
            when 'submit'
                element.send :"#{operate_type}"
            when 'click'
                is_hide_keyboard
                element.send :"#{operate_type}"
            when 'select_list'
                Selenium::WebDriver::Support::Select.new(element).select_by :text, content.to_s
            when 'app_sliding'
                action = Appium::TouchAction.new.press(x: content['start']['x'], y: content['start']['y']).move_to(x: content['target']['x'], y: content['target']['y']).release
                action.perform
            # when 'script'
                # self.send :"#{content}"
        end
    end

    def operate_driver(type, content=nil)
        case type
            when 'forward'
                driver.navigate.forward
            when 'back'
                driver.navigate.back
            when 'switch_to'
                driver.switch_to.frame(content)
        end
    end

    def analysis_element(args)
        result = ''
        case args[:type]
            when 'text'
                result = args[:element].text
            when 'selected'
                result = args[:element].selected?
            when 'tag_name'
                result = args[:element].tag_name
            when 'is_enabled'
                result = args[:element].enabled?
            when 'is_displayed'
                result = args[:element].displayed?
            when 'attribute'
                result = args[:element].attribute
            when 'alert'
                result = close_alert_and_get_its_text if alert_present?
            when 'is_alert'
                result = alert_present?
                close_alert_and_get_its_text if alert_present?
                result
            when 'element_array'
                result = args[:element]
            else
                raise "元素操作类型:#{args[:type]}不支持,请扩展类型或者另选其它类型!!!!"
            # when 'element_array'
            #     result = self.send :"#{args[:script]}", :element_array => args[:element], :control => args[:control]
        end
        result
    end

    def analysis_driver(type, content=nil)
        case type
            when 'title'
                result = driver.title
            when 'url'
                result = driver.current_url
            else
                raise "驱动操作类型:#{args[:type]}不支持,请扩展类型或者另选其它类型!!!!"
        end
        result
    end

    def receive_param_from_element(args)
        self.args = args
    end

    def element_present?(how, what, is_script_condition)
        logger(args[:auto_control]['project']).info "查询元素 how:#{how} what:#{what}"
        case is_script_condition
            when 'script'
                element = driver.execute_script(what)
            when 'find_element'
                element = driver.find_element(how, what)
            when 'find_elements'
                element = driver.find_elements(how, what)
            else
                raise "元素查询类型:#{is_script_condition}不支持,请扩展类型或者另选其它类型!!!!"
        end
        element
        # true
    rescue Selenium::WebDriver::Error::NoSuchElementError
        # raise '元素,未找到!!!!!!........'
        false
    end

    def element_present_no_raise?(how, what)
        logger(args[:auto_control]['project']).info "查询元素 how:#{how} what:#{what}"
        @driver.find_element(how,what)
        true
    rescue Selenium::WebDriver::Error::NoSuchElementError
        false
    end
    #是否有警告信息
    def alert_present?
        @driver.switch_to.alert
        true
    rescue Selenium::WebDriver::Error::NoAlertPresentError
        false
    end

    # def verify(&blk)
    # 	yield
    # rescue ExpectationNotMetError => ex
    # 	@verification_errors << ex
    # end
    #有警告窗口，处理并且获得警告信息
    def close_alert_and_get_its_text
        alert = @driver.switch_to().alert()
        alert_text = alert.text
        if (@accept_next_alert) then
            alert.accept()
        else
            alert.dismiss()
        end
        alert_text
    ensure
        @accept_next_alert = true
    end

    def match_element_content(element_index, element_content, element_data)
        element_value = ''
        if element_content.has_key?(element_index)
            element_value = element_content[element_index]
        else
            logger("#{args[:auto_control]['project']}").info "元素是否包含操作值：在#{element_content}中不存在元素:#{element_index},或者操作类型不是send_keys"
        end
        element_value
    end
    
    def is_hide_keyboard
        captured_content = capture_stdout do
            system('adb shell dumpsys input_method | grep mInputShown')
        end
        res = captured_content.chop.include?('mInputShown=true')
        puts "is_keyboard:#{res}"
        if res
            driver.hide_keyboard 
        end
    end
end