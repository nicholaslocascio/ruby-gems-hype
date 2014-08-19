require 'gems'
require 'pp'

namespace :db do
  desc "Update Repo Download Count"
  task :update_repo_download_count,  [:partition] => :environment do |t, args|


    # Set up partition
    number_of_repos = Repo.count
    partition_size = (number_of_repos/20).to_i
    partition_offset = args[:partition].to_i*partition_size

    # Get all repos in partition
    repos_to_process = Repo.all().limit(partition_size).offset(partition_offset)

    repos_to_process.each do |repo|
      # Return some basic information about rails
      info = Gems.info repo.name
      pp info
      if info and info["downloads"]
        repo.download_count = info["downloads"]
      end
      repo.save!
    end
  end
end
