
class CtxBase < ActiveRecord::Base
  self.abstract_class=true
  establish_connection 'ctx'
end

class LearnWord < CtxBase
  self.table_name = "learn_words"
end
