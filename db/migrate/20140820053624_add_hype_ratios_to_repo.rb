class AddHypeRatiosToRepo < ActiveRecord::Migration
  def change
    add_column :repos, :star_to_reference_ratio, :float
    add_column :repos, :star_to_download_ratio, :float
  end
end
