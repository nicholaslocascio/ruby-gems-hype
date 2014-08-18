class Repo < ActiveRecord::Base
  def self.containing_hype_score
    Repo.where("repos.hype_score IS NOT NULL")
  end
end
