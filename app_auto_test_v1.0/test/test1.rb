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

opts = {caps:{deviceName: 'HC46GWY04694', platformName: 'Android', appActivity: '.WelcomeActivity', appPackage: 'com.tcg.penny'},
        appium_lib: { sauce_username: nil, sauce_access_key: nil}}
driver = Appium::Driver.new(opts)
driver.start_driver

###登录
element = driver.find_element('id', 'com.tcg.penny:id/account')
is_hide_keyboard
element.send_keys('13764905634')
element = driver.find_element('id', 'com.tcg.penny:id/passwrod')
is_hide_keyboard
element.send_keys('111111')
element = driver.find_element('id', 'com.tcg.penny:id/logining')
is_hide_keyboard
element.click

#礼品
element = driver.find_element('id', 'com.tcg.penny:id/select_btn_gift')
element.click
elements = driver.find_elements(:xpath=>"//android.widget.TextView")
for i in 0..elements.size-1
    puts elements[i].text
end
# puts "size:#{size}"
# for i in 0..size-1
    # element = driver.find_element('xpath', "//android.widget.ListView[1]//android.widget.LinearLayout[#{i}]//android.widget.TextView[0]")
    # puts element.text
    # element = driver.find_element('xpath', "//android.widget.ListView[1]//android.widget.LinearLayout[#{i}]//android.widget.TextView[1]")
    # puts element.text
# end
###登录

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
