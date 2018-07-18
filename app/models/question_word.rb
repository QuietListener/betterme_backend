
class PapBase < ActiveRecord::Base
  self.abstract_class=true
  establish_connection :pap
end

class QuestionWord < PapBase
  self.table_name = "word_topics"

  def self.getQuestion(limit,choice_count=3)

     offset1 = rand(1000);
     qws = QuestionWord.offset(offset1).limit(limit)

     choice_count = limit * choice_count;
     offset2 = rand(1000);
     choices =  QuestionWord.offset(offset2).limit(choice_count)

     return qws,choices
  end

end
