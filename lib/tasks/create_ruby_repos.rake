require 'csv'

namespace :db do
  desc "Create Ruby Repos"
  task :create_ruby_repos => :environment do
    CSV.foreach(File.join(Rails.root, "data", "ruby_repos.csv"), headers:true, header_converters: :symbol, converters: :all) do |repo|
      repo_name = repo[:repository_name].to_s
      puts repo_name
      if Repo.exists?(:name => repo_name)
        next
      end
      @current_repo = Repo.create(:name => repo_name)

      url = repo[:repository_url]
      url_components = url.split('/')
      repo_full_name = url_components[-2] + "/" + url_components[-1]

      @current_repo.full_name = repo_full_name
      @current_repo.save!
    end
  end
end
