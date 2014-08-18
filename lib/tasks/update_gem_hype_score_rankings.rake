namespace :db do
  desc "Update Gem Hype Score Rankings"
  task :update_gem_hype_score_rankings => :environment do
    repo_count = Repo.count
    number_of_batches = 1000
    rank = 1
    batch_size = repo_count/number_of_batches

    (0..number_of_batches).each do |batch_index|
      offset = batch_index*batch_size
      Repo.order("hype_score DESC").limit(batch_size).offset(offset).all.each do |repo|
        repo.hype_rank = rank
        repo.save!
        rank += 1
      end
    end
  end
end
