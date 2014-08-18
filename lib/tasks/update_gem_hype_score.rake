namespace :db do
  desc "Update Gem Hype Score"
  task :update_gem_hype_score => :environment do

    Repo.all().each do |repo|
      if repo.stargazers_count.nil? or repo.referenced_count.nil? or repo.stargazers_count < 1 or repo.referenced_count < 1
        next
      end
      hype_ratio = (repo.stargazers_count.to_f / repo.referenced_count.to_f)
      repo.hype_score = sigmoid(hype_ratio)
      repo.save!
    end
  end
end


def sigmoid(x)
  return 1.0/(1+Math.exp(-x))
end
