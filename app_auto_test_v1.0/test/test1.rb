#encoding:utf-8
require 'appium_lib'
def element_present?(how, what, driver)
    # logger(@args[:control_value]['project']).info "查询元素 how:#{how} what:#{what}"
    driver.find_element(how,what)
    true
rescue Selenium::WebDriver::Error::NoSuchElementError
    raise '元素,未找到!!!!!!........'
    false
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

def is_keyboard
    captured_content = capture_stdout do
        system('adb shell dumpsys input_method | grep mInputShown')
    end
    captured_content.chop.include?('mInputShown=true')
end

opts = {caps:{deviceName: 'HC46GWY04694', platformName: 'Android', appActivity: '.WelcomeActivity', appPackage: 'com.tcg.penny'},
        appium_lib: { sauce_username: nil, sauce_access_key: nil}}
driver = Appium::Driver.new(opts)
driver.start_driver

begin_time = Time.now.to_i
end_time = 0
# num = 1
while end_time < begin_time + 63
    # x = [200,348,440]
    # y = [648,854,1036]
    # x_i = x[rand(0..2)]
    # y_i = y[rand(0..2)]
    x = [154]
    y = [630]
    x_i = x[0]
    y_i = y[0]
    action = Appium::TouchAction.new.tap(x: x_i, y: y_i).release
    action.perform
    end_time = Time.now.to_i
    # puts "x_i:#{x_i}"
    # puts "y_i:#{y_i}"
    # num+=1
    sleep(0.5)
end


###登录
# element = driver.find_element('id', 'com.tcg.penny:id/pwd_cb')
# puts element.selected?
# puts element.enabled?
# puts element.tag_name
# puts element.displayed?
# element = driver.find_element('id', 'com.tcg.penny:id/account_cb')
# puts element.selected?
# puts element.enabled?
# puts element.tag_name
# puts element.displayed?
# puts element.attribute('class')
# element = driver.find_element('id', 'com.tcg.penny:id/passwrod')
# element.send_keys('11111')
# element = driver.find_element('id', 'com.tcg.penny:id/logining')
# element.click
###注册
# sleep(10)
# driver.close_app
# for i in 0..7
    # if i == 0
        # element = driver.find_element('id', 'com.tcg.penny:id/register_tab_static')
        # element.click
    # end
    # element = driver.find_element('id', 'com.tcg.penny:id/account_register')
    # element.clear
    # if is_keyboard
        # # sleep(0.5)
        # driver.hide_keyboard 
    # end
    # element.send_keys('13764905631')
    # element = driver.find_element('id', 'com.tcg.penny:id/re_verifica')
    # element.click
    # element = driver.find_element('id', 'com.tcg.penny:id/verfication_code')
    # element.clear
    # if is_keyboard
        # # sleep(0.5)
        # driver.hide_keyboard 
    # end
    # element.send_keys('0000')
    # element = driver.find_element('id', 'com.tcg.penny:id/passwrod_register')
    # element.clear
    # if is_keyboard
        # # sleep(0.5)
        # driver.hide_keyboard 
    # end
    # element.send_keys('1111111')
    # element = driver.find_element('id', 'com.tcg.penny:id/invite_code')
    # element.clear
    # if is_keyboard
        # # sleep(0.5)
        # driver.hide_keyboard 
    # end
    # element.send_keys('aGM26T')
# end
