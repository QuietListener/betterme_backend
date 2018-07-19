class CpSession < ActiveRecord::Base

  def user1
    User.where(:id=>self.user1_id).first
  end

  def user2
    User.where(:id=>self.user2_id).first
  end

  def responde_data
      words_id = self.words_ids||"";
      choices_words_ids = self.choices_words_ids||""

      words_id_array = words_id.split(",")
      choices_words_ids_array = choices_words_ids.split(",")

      qws = QuestionWord.where(:id=>words_id_array)
      choices_ = QuestionWord.where(:id=>choices_words_ids_array).map{|item|item}

      questions = qws.map.with_index do |item,index|

       ret = {
            word:item,
            choices:choices_[index*3,3]
        }
       ret
      end


    return questions
  end

  def as_json_data
    ret = self.as_json(:include=>[:user1, :user2])
    responde_data_ = self.responde_data

    ret[:responde_data] = responde_data_
    return ret;
  end

end
