class AddDownloadCountToRepos < ActiveRecord::Migration
  def change
    add_column :repos, :download_count, :integer
  end
end
