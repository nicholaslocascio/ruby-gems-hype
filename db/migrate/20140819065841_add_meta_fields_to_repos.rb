class AddMetaFieldsToRepos < ActiveRecord::Migration
  def change
    add_column :repos, :repo_created_at, :datetime
    add_column :repos, :forks_count, :integer
  end
end
