namespace :db do
  desc "Clear Ruby Repo Stats"
  task :clear_ruby_repo_stats => :environment do

    # Clear all accumulatable stats
    Repo.find_each do |repo|
      repo.hype_score = 0
      repo.references_count = 0
      repo.referenced_count = 0
    end
  end
end
