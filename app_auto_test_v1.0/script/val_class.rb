#encoding:UTF-8
# require 'script/romdu_back_val'
require 'script/romdu_front_val'
require 'check/validation'
require 'script/game_center'

class ValClass < Validation
    include RomduFrontVal
    include GameCenter
    include GameCenter::InitData
end