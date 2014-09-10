#encoding:utf-8
require 'appium_lib'
def element_present?(how, what, driver)
    driver.find_element(how,what)
    true
rescue Selenium::WebDriver::Error::NoSuchElementError
    raise '元素,未找到!!!!!!........'
    false
end
opts = {caps:{deviceName: 'HC46GWY04694', platformName: 'Android', appActivity: '.WelcomeActivity', appPackage: 'com.tcg.penny'},
        appium_lib: { sauce_username: nil, sauce_access_key: nil}}
driver = Appium::Driver.new(opts).start_driver
element = driver.find_element('id', 'com.tcg.penny:id/account')
element.send_keys('13764905631')
element = driver.find_element('id', 'com.tcg.penny:id/passwrod')
element.send_keys('111111')
element = driver.find_element('id', 'com.tcg.penny:id/logining')
element.click
sleep(5)

if element_present?('id', 'com.tcg.penny:id/select_btn_help', driver)
    system('adb shell monkey -p com.tcg.penny -s 500 --ignore-crashes --ignore-timeouts --monitor-native-crashes -v -v 10000 > E:\360CloudUI\Cache\20655813\android_test\monkey_test\penny_log.txt')
end
