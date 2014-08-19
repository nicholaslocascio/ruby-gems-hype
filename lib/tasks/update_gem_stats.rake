
namespace :db do
  desc "Update Gem Stats"
  task :update_gem_stats,  [:partition] => :environment do |t, args|

    # Set up client
    Octokit.configure do |c|
      c.client_id = ENV['GH_BASIC_CLIENT_ID_' + args[:partition] ]
      c.client_secret = ENV['GH_BASIC_SECRET_ID_' + args[:partition] ]
    end
    client = Octokit::Client.new(per_page: 100)

    # Set up partition
    number_of_repos = Repo.count
    partition_size = (number_of_repos/20).to_i
    partition_offset = args[:partition].to_i*partition_size

    # Get all repos in partition
    repos_to_process = Repo.all().limit(partition_size).offset(partition_offset)

    repos_to_process.each do |repo|

      sleep_if_rate_limit_hit(client)

      begin
        remote_repo_data = client.repo(repo.full_name)
      rescue Exception=>e
        Rails.logger.info"Failed to get repo for " + repo.full_name
        Rails.logger.debug e
        next
      end

      repo.stargazers_count = remote_repo_data["stargazers_count"]
      repo.watchers_count = remote_repo_data["watchers_count"]
      repo.description = remote_repo_data["description"]
      repo.repo_created_at = remote_repo_data["created_at"]
      repo.forks_count = remote_repo_data["forks_count"]
      repo.save!

      # Get Gemfile of repo
      gemfile_response = nil
      begin
        gemfile_response = client.contents(repo.full_name, :path => 'Gemfile')
      rescue Exception=>e
        Rails.logger.info "Failed to get GemFile for " + repo.full_name
        Rails.logger.debug e
        next
      end
      Rails.logger.info "Succesfully got GemFile for " + repo.full_name

      @referenced_gems_data = referenced_gems_data_from_gemfile_response(gemfile_response)
      if @referenced_gems_data.nil?
        next
      end

      dependencies = @referenced_gems_data.dependencies
      repo.references_count = dependencies.count
      repo.save!
      dependencies.each do |gem_data|
        gem_data = gem_data[0]
        referenced_gem_name = gem_data.name

        @referenced_repo = Repo.find_or_create_by(:name => referenced_gem_name)

        if @referenced_repo.referenced_count.nil?
          @referenced_repo.referenced_count = 0
        end
        @referenced_repo.referenced_count += 1
        @referenced_repo.save!
      end
    end
  end
end

def referenced_gems_data_from_gemfile_response(gemfile_response)
  gem_file_text = base64_url_decode(gemfile_response.content)
  referenced_gems_data = Gemnasium::Parser::Gemfile.new(strip_bad(gem_file_text.to_s))
  return referenced_gems_data
end

def strip_bad(string)
  indent = string.scan(/^[ \t]*(?=\S)/)
  n = indent ? indent.size : 0
  string.gsub(/^[ \t]{#{n}}/, "")
  return string
end

def base64_url_decode(str)
  str += '=' * (4 - str.length.modulo(4))
  Base64.decode64(str.tr('-_','+/'))
end

def sleep_if_rate_limit_hit(client)
  if client.rate_limit.remaining < 2
    sleep_time = client.rate_limit.resets_in.to_i
    if sleep_time > 0
      puts "sleeping for #{sleep_time} seconds"
      sleep sleep_time
    end
  end
end
