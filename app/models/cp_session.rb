class CpSession < ActiveRecord::Base

  def responde_data
      words_id = self.words_ids||"";
      choices_words_ids = self.choices_words_ids||""

      words_id_array = words_id.split(",")
      choices_words_ids_array = choices_words_ids.split(",")

      qws = QuestionWord.where(:id=>words_id_array)
      choices = QuestionWord.where(:id=>choices_words_ids_array)

      questions = qws.map do |item,index|

        return {
            word:item,
            choices:choices[index*3,index*3+3]
          }
      end

    return questions
  end

  def as_json_data
    self.as_json(:include=>[:responde_data])
  end

end
