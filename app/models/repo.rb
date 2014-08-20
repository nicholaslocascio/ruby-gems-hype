class Repo < ActiveRecord::Base
  def self.containing_hype_score
    Repo.where("repos.hype_score IS NOT NULL")
  end

  def self.containing_star_to_reference_ratio
    Repo.where("repos.star_to_reference_ratio IS NOT NULL")
  end

  def self.containing_star_to_download_ratio
    Repo.where("repos.star_to_download_ratio IS NOT NULL")
  end
end
