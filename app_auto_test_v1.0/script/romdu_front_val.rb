#encoding:UTF-8
# require 'database/database'
# require 'common/base'
require 'common/log'

module RomduFrontVal
    include MyLog
    # include MyBase
    # def get_query(fields, table, conditions, dbc)
    #     sql = "select #{fields} from #{table} where #{conditions}"
    #     res = dbc.query(sql)
    #     res
    # end

    def front_login_val(args)
        'http://www.alpha.romdu.com/index.php/main/index'
    end

    def front_revenue_trend_val(args)
        '收益日趋势'
    end

    def front_install_income_val(args)
        #数据库查询逻辑计算
        '￥0.00'
    end

    def front_activate_income_val(args)
        #数据库查询逻辑计算
        '￥0.00'
    end

    def front_agent_income_val(args)
        #数据库查询逻辑计算
        '￥0.00'
    end

    def front_bonus_val(args)
        #数据库查询逻辑计算
        '￥16707.48'
    end

    def val_income_details(element_array)
        puts element_array[0].text.split(' ')
    end

end
# include RomduFrontVal
# mysql = MysqlC.new
# puts data_revenue_trend_day(nil,mysql,nil,nil)
# puts data_revenue_trend_day(nil,mysql,nil,nil)
# puts down_income_all(data_revenue_trend_day(nil,mysql,nil,nil))
# puts front_agent_price_rom_spread_all(nil,mysql,nil,nil)