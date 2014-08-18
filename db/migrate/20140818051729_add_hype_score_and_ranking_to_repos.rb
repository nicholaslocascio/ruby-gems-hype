class AddHypeScoreAndRankingToRepos < ActiveRecord::Migration
  def change
    add_column :repos, :hype_score, :float
    add_column :repos, :hype_rank, :integer
  end
end
