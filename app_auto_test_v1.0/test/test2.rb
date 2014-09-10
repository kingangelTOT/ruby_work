#encoding:utf-8
require 'appium_lib'

begin_time = Time.now.to_i
end_time = 0
# num = 1
while end_time < begin_time + 63
    x = [138,348,565]
    y = [648,854,1036]
    x_i = x[rand(0..2)]
    y_i = y[rand(0..2)]
    action = Appium::TouchAction.new.press(x: x_i, y: y_i).release
    action.perform
    end_time = Time.now.to_i
    # puts "x_i:#{x_i}"
    # puts "y_i:#{y_i}"
    # num+=1
    # sleep(0.5)
end