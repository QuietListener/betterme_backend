class Video < ActiveRecord::Base

  belongs_to :utype,:foreign_key => :utype_id
end
