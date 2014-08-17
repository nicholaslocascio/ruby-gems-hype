class CreateRepos < ActiveRecord::Migration
  def change
    create_table :repos do |t|
      t.string :name
      t.string :full_name
      t.text :description
      t.integer :stargazers_count
      t.integer :watchers_count
      t.integer :referenced_count
      t.integer :references_count

      t.timestamps
    end
    add_index :repos, :name, unique: true
  end
end
