#encoding:utf-8
require 'appium_lib'
require 'common/http'
require 'common/log'
module GameCenter
    include Http
    include MyLog
    module InitData
        def init_account_management(*args)
            input_extract_wechat1 = [*'a'..'z'].sample(5).join
            input_extract_wechat2 = [*'a'..'z'].sample(5).join
            input_extract_wechat3 = [*'a'..'z'].sample(5).join
            logger(args[1]['project']).info "初始化微信账号:#{input_extract_wechat1} 位置:{C2}"
            logger(args[1]['project']).info "初始化微信账号:#{input_extract_wechat2} 位置:{C3}"
            logger(args[1]['project']).info "初始化微信账号:#{input_extract_wechat3} 位置:{C4}"
            args[0].Range('C2').value = [input_extract_wechat1]
            args[0].Range('C3').value = [input_extract_wechat2]
            args[0].Range('C4').value = [input_extract_wechat3]
        end
        
        def init_registration(*args)
            phone = '13700000'
            rand = rand_num(3)
            phone << rand.to_s
            logger(args[1]['project']).info "初始化位置:{B9};手机号:#{phone}"
            args[0].Range('B9').value = [phone]
        end
        
        def init_forget_pwd(*args)
            
        end
        
        def init_login(*args)
            phone = '137'
            rand = rand_num(8)
            phone << rand.to_s
            logger(args[1]['project']).info "初始化位置:{B4};手机号:#{phone}"
            args[0].Range('B4').value = [phone]
            # args[0].Range('C4').value = ['afadf9']
        end
        
        def init_select_scene(*args)
            
        end
        
        def init_game_description(*args)
            
        end
        
        def rand_num(bit)
            a = ''
            for i in 0..bit-2
                a = a << '0'
            end
            num = '1' << a
            data = [*('0'..'9')].sample(bit).join.to_i
            if data < num.to_i
                rand_num(bit)
            else 
                return data
            end
        end
    end
    
    def task_app_by_user(mysql, control_value)
        
    end

    def task
        
    end

    def get_agent(id)
        sql = "SELECT parent_id FROM gc_agent WHERE id = #{id}"
        res = mysql.get_from_sql(sql)
        id = 0
        res.each {|row|
            puts
            id = row['parent_id']
        }
        id
    end

    def select_by_sql(mysql, flied, table, conditions, get_flied_names)
        sql = "SELECT #{flied} FROM #{table} WHERE #{conditions}"
        puts sql
        res = mysql.get_from_sql(sql)
        array = Array.new
        return array if res.size == 0
        if get_flied_names.size >= 1
            res.each {|row|
                data = Hash.new
                puts "get_flied_names:#{get_flied_names}"
                puts "row:#{row}"
                get_flied_names.each { |field|
                    data[field] = row[field] 
                }
                array << data
                puts "bid_array:#{array}"
                puts '*******************************'
            }
            return array
        else
            return res
        end 
    end

    def task_type_by_app(res, control_value)
        res.each {|row|

        }
    end

    def panny_random_click_screen(*args)
        # args[0].element_present_no_raise('find_element', 'id', 'com.tcg.penny:id/dialog_gift_more')
        # puts args[0].class
        begin_time = Time.now.to_i
        end_time = 0
        # num = 1
        while end_time < begin_time + 63
            x = [138,348,565]
            y = [648,854,1036]
            x_i = x[rand(0..2)]
            y_i = y[rand(0..2)]
#             
            # x = [154]
            # y = [630]
            # x_i = x[0]
            # y_i = y[0]
            action = Appium::TouchAction.new.tap(x: x_i, y: y_i).release
            action.perform
            end_time = Time.now.to_i
            # puts "x_i:#{x_i}"
            # puts "y_i:#{y_i}"
            # num+=1
            # sleep(0.5)
            # sleep(0.5)
        end
    end
    
    def sliding_game(*args)
        sleep(3)
        action = Appium::TouchAction.new.press(x: 719, y: 900).move_to(x: 20, y: 900).release
        action.perform
    end
    
    def script_get_verifica(*args)
        hostName = 'http://playhamster.alpha.yueapp.com'
        path = '/test/memcached/get-by-key/'
        param = "key=GC_SMS_#{args[0]}"
        hash = JSON.parse(http_post(hostName,path,param,'game_center'))
        # raise "game_center脚本中的script_get_verifica方法,获取验证码失败...." if !hash['verify']
        result = hash['verify']
        result = '0000' if !result
        result
    end
    
    def get_uuid_by_phone(val,database_name,phone)
        mysql_basis = val.init_select_database(database_name)
        uuid = select_by_sql(mysql_basis, '*', 't_user', "f_user_phone = #{phone}", ['f_uuid'])[0]['f_uuid']
        "'#{uuid}'"
    end
    
    def get_transmit_value(transmit_hash)
        need_element_value_hash = Hash.new
        transmit_hash['need_script_param'].each{|need_element_name|
              need_element_value_hash[need_element_name] = transmit_hash['transmit_value'][need_element_name]
        }
        need_element_value_hash
    end
    
    def get_game_money_amount(*args)
        # mysql_basis = args[4].init_select_database(args[2][1])
        # uuid = select_by_sql(mysql_basis, '*', 't_user', "f_user_phone = #{args[3]}", ['f_uuid'])['f_uuid']
        # uuid = "'#{uuid}'"
        need_element_value_hash = get_transmit_value(args[3])
        uuid = get_uuid_by_phone(args[4], args[2][1], need_element_value_hash['account'])
        mysql_gamecenter = args[4].init_select_database(args[2][0])
        game_coin = select_by_sql(mysql_gamecenter, '*', 'gc_user', "UUID = #{uuid}", ['game_coin'])[0]['game_coin']
        game_coin
    end
    
    def get_extract_money_amount(*args)
        need_element_value_hash = get_transmit_value(args[3])
        uuid = get_uuid_by_phone(args[4], args[2][1], need_element_value_hash['account'])
        mysql_gamecenter = args[4].init_select_database(args[2][0])
        game_coin_enable = select_by_sql(mysql_gamecenter, '*', 'gc_user', "UUID = #{uuid}", ['game_coin_enable'])[0]['game_coin_enable']
        game_coin_enable
    end
    
    def is_withdraw_successful(*args)
        need_element_value_hash = get_transmit_value(args[3])
        uuid = get_uuid_by_phone(args[4], args[2][1], need_element_value_hash['account'])
        mysql_gamecenter = args[4].init_select_database(args[2][0])
        data_hash = select_by_sql(mysql_gamecenter, '*', 'gc_log_game_coin', "UUID = #{uuid} AND coin = #{need_element_value_hash['input_extract_money']} AND note = '#{need_element_value_hash['input_extract_wechat']}'", ['id'])
        return 'no_record' if data_hash.length == 0
        return 'record' if data_hash.length == 1
        return '数据库查询异常' if data_hash.length >= 1
    end
    
    def validate_extract_money_amount(*args)
        need_element_value_hash = get_transmit_value(args[3])
        uuid = get_uuid_by_phone(args[4], args[2][1], need_element_value_hash['account'])
        mysql_gamecenter = args[4].init_select_database(args[2][0])
        extract_money_amount_all = select_by_sql(mysql_gamecenter, 'SUM(coin) AS aaa', 'gc_log_game_coin', "UUID = #{uuid} AND TYPE = 2", ['aaa'])[0]['aaa'].to_i
        withdrawed_money = select_by_sql(mysql_gamecenter, 'SUM(coin) AS bbb', 'gc_log_game_coin', "UUID = #{uuid} AND TYPE = 4", ['bbb'])[0]['bbb'].to_i
        extract_money_amount = get_extract_money_amount(args[1],args[2],args[3],args[4]).to_i
        all = withdrawed_money + extract_money_amount
        return 'is_true' if all == extract_money_amount_all
        return 'is_false' if all != extract_money_amount_all
    end
    
    def validate_subtract_money(*args)
        need_element_value_hash = get_transmit_value(args[3])
        uuid = get_uuid_by_phone(args[4], args[2][1], need_element_value_hash['account'])
        mysql_gamecenter = args[4].init_select_database(args[2][0])
        
        subtract_coin = select_by_sql(mysql_gamecenter, '*', 'gc_log_game_coin', "id = (SELECT MAX(id) FROM gc_log_game_coin WHERE UUID = #{uuid} AND TYPE = 2)", ['coin'])[0]['coin'].to_i
        game_money_amount = select_by_sql(mysql_gamecenter, '*', 'gc_user', "UUID = #{uuid}", ['game_coin'])[0]['game_coin'].to_i
        case need_element_value_hash['select_num_title'][0]
            when '1'
                all = 50 + game_money_amount
                return 'Subtract_50' if  need_element_value_hash['select_total_coin'].to_i == all
                return 'no_Subtract_50' if  need_element_value_hash['select_total_coin'].to_i != all
            when '2'
                all = 100 + game_money_amount
                return 'Subtract_100' if  need_element_value_hash['select_total_coin'].to_i == all
                return 'no_Subtract_100' if  need_element_value_hash['select_total_coin'].to_i != all
            when '3'
                all = 200 + game_money_amount
                return 'Subtract_200' if  need_element_value_hash['select_total_coin'].to_i == all
                return 'no_Subtract_200' if  need_element_value_hash['select_total_coin'].to_i != all
            when '4'
                all = 500 + game_money_amount
                return 'Subtract_500' if  need_element_value_hash['select_total_coin'].to_i == all
                return 'no_Subtract_500' if  need_element_value_hash['select_total_coin'].to_i != all
            when '5'
                all = 1000 + game_money_amount
                return 'Subtract_1000' if  need_element_value_hash['select_total_coin'].to_i == all
                return 'no_Subtract_1000' if  need_element_value_hash['select_total_coin'].to_i != all
            when '6'
                all = 2000 + game_money_amount
                return 'Subtract_2000' if  need_element_value_hash['select_total_coin'].to_i == all
                return 'no_Subtract_2000' if  need_element_value_hash['select_total_coin'].to_i != all
            when '7'
                all = 5000 + game_money_amount
                return 'Subtract_5000' if  need_element_value_hash['select_total_coin'].to_i == all
                return 'no_Subtract_5000' if  need_element_value_hash['select_total_coin'].to_i != all
            when '8'
                all = 8000 + game_money_amount
                return 'Subtract_8000' if  need_element_value_hash['select_total_coin'].to_i == all
                return 'no_Subtract_8000' if  need_element_value_hash['select_total_coin'].to_i != all
            when '9'
                all = 10000 + game_money_amount
                return 'Subtract_10000' if  need_element_value_hash['select_total_coin'].to_i == all
                return 'no_Subtract_10000' if  need_element_value_hash['select_total_coin'].to_i != all
        end
    end
    
    def validate_box(*args)
        box_string = ''
        need_element_value_hash = get_transmit_value(args[3])
        uuid = get_uuid_by_phone(args[4], args[2][1], need_element_value_hash['account'])
        mysql_gamecenter = args[4].init_select_database(args[2][0])
        create_time = select_by_sql(mysql_gamecenter, 'create_time', 'gc_user_ware', "id = (SELECT MAX(id) FROM gc_user_ware WHERE UUID = #{uuid})", ['create_time'])['create_time'].to_i
        puts "create_time:#{create_time}"
        create_time_new = Time.at(create_time-60)
        
        data = select_by_sql(mysql_gamecenter, '*', 'gc_user_ware', "UUID = #{uuid} AND create_time > '#{create_time_new}' AND create_time <= (SELECT create_time FROM gc_user_ware WHERE id = (SELECT MAX(id) FROM gc_user_ware WHERE UUID = #{uuid}))",[])
        puts "data:#{data}"
        case need_element_value_hash['select_num_title'][0]
            when '1'
                box_string = "游戏结束，您获得了#{data.count}个宝箱，50金币，请尽快抽奖。"
            when '2'
                box_string = "游戏结束，您获得了#{data.count}个宝箱，100金币，请尽快抽奖。"
            when '3'
                box_string = "游戏结束，您获得了#{data.count}个宝箱，200金币，请尽快抽奖。"
            when '4'
                box_string = "游戏结束，您获得了#{data.count}个宝箱，500金币，请尽快抽奖。"
            when '5'
                box_string = "游戏结束，您获得了#{data.count}个宝箱，1000金币，请尽快抽奖。"
            when '6'
                box_string = "游戏结束，您获得了#{data.count}个宝箱，2000金币，请尽快抽奖。"
            when '7'
                box_string = "游戏结束，您获得了#{data.count}个宝箱，5000金币，请尽快抽奖。"
            when '8'
                box_string = "游戏结束，您获得了#{data.count}个宝箱，8000金币，请尽快抽奖。"
            when '9'
                box_string = "游戏结束，您获得了#{data.count}个宝箱，10000金币，请尽快抽奖。"
        end
        box_string     
    end
    
    def get_gift_string(*args)
        result = ''
        args[5][0..8].each{|element|
            result << element.text
        }
        result
    end
    
    def validate_gift(*args)
        box_string = '礼品'
        need_element_value_hash = get_transmit_value(args[3])
        uuid = get_uuid_by_phone(args[4], args[2][1], need_element_value_hash['account'])
        mysql_gamecenter = args[4].init_select_database(args[2][0])
        bid_array = select_by_sql(mysql_gamecenter, '*', 'gc_user_ware', "UUID = #{uuid} ORDER BY id DESC LIMIT 0,4", ['bid','create_time'])
        puts "bid_array:#{bid_array}"
        bid_array.each{|hash|
            gift_array = select_by_sql(mysql_gamecenter, '*', 'gc_app_box', "id = #{hash['bid']}", ['name','description'])
            gift_array.each{|git_hash|
                box_string << git_hash['name']
                box_string << git_hash['description']
                box_string << '  '
                box_string << "#{hash['create_time'].to_s.sub ' +0800',''}"
            }
        }
        box_string
    end
end