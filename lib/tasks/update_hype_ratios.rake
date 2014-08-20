namespace :db do
  desc "Update Hype Ratios"
  task :update_hype_ratios => :environment do

    Repo.find_each do |repo|

      referenced_count = repo.referenced_count
      if referenced_count and referenced_count > 0
        star_to_reference_ratio = (repo.stargazers_count.to_f / referenced_count)
        repo.star_to_reference_ratio = star_to_reference_ratio
      end

      download_count = repo.download_count
      if download_count and download_count > 0
        star_to_download_ratio = (repo.stargazers_count.to_f / download_count)
        repo.star_to_download_ratio = star_to_download_ratio
      end
      puts repo.name + ", star_to_download_ratio: " + repo.star_to_download_ratio.to_s + ", star_to_reference_ratio: " + repo.star_to_reference_ratio.to_s
      repo.save!
    end
  end
end
