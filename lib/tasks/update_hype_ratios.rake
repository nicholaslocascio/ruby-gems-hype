namespace :db do
  desc "Update Hype Ratios"
  task :update_hype_ratios => :environment do

    Repo.find_each do |repo|
      if repo.stargazers_count.nil? or repo.referenced_count.nil? or repo.stargazers_count < 1 or repo.referenced_count < 1
        next
      end
      star_to_reference_ratio = (repo.stargazers_count.to_f / repo.referenced_count.to_f)
      star_to_download_ratio = (repo.stargazers_count.to_f / repo.download_count.to_f)
      repo.star_to_reference_ratio = star_to_reference_ratio
      repo.star_to_download_ratio = star_to_download_ratio
      puts repo.name + ", star_to_download_ratio: " + repo.star_to_download_ratio.to_s + ", star_to_reference_ratio: " + repo.star_to_reference_ratio.to_s
      repo.save!
    end
  end
end
