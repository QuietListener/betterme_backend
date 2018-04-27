class UserPackage < ActiveRecord::Base

  TypeFinished = 0
  TypeLike = 1
  TypePlayed  = 2

  def package
    return Package.where(:id=>self.package_id).first
  end

end
