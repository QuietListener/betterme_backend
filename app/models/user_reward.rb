class UserReward < ActiveRecord::Base

  StateInit = 0
  StateDone = 1
  StateError = 2

  #每日计划完成
  TypeDayTaskFinishedReward = 0

  #创建计划
  TypeCreatePlan = 1

  #打卡奖励
  TypeDakaReward = 2

  #每日计划完成
  TypeInitReward = 3
end
