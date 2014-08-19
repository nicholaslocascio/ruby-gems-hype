namespace :db do
  desc "Update Gem Hype Score"
  task :update_gem_hype_score => :environment do

    Repo.find_each do |repo|
      if repo.stargazers_count.nil? or repo.referenced_count.nil? or repo.stargazers_count < 1 or repo.referenced_count < 1
        next
      end
      hype_referenced_ratio = (repo.stargazers_count.to_f / repo.referenced_count.to_f)
      hype_download_ratio = (repo.stargazers_count.to_f / repo.download_count.to_f)
      repo.hype_score = 50*(sigmoid(hype_ratio) + sigmoid(hype_download_ratio))
      puts repo.name + ", hype_score: " + repo.hype_score.to_s
      repo.save!
    end
  end
end


def sigmoid(x)
  return 1.0/(1.0+Math.exp((-1.0*x) - 0.5))
end
