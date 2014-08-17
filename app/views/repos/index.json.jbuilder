json.array!(@repos) do |repo|
  json.extract! repo, :id, :name, :full_name, :stargazers_count, :referenced_count, :references_count
  json.url repo_url(repo, format: :json)
end
