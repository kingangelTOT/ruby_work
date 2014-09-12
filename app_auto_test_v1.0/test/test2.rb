#encoding:utf-8

    def log_cat_android()
        t1 = Thread.new {
            system("adb logcat>E:\auto_test\log\test_android.txt")
        }
        
        t2 = Thread.new {
            sleep(3)
            system('taskkill /f /im adb.exe')
            # t1.kill
        }
        t1.join
        t2.join
    end
    log_cat_android
