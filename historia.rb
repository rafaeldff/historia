require 'sinatra'
require 'json'
require 'rugged'

def get_commits
  repo = Rugged::Repository.new("/home/rff/bin/rgit")
  walker = Rugged::Walker.new(repo)
  walker.push(repo.head.target)
  commits = [].tap do |commits|
    walker.each {|c| commits.push message: c.message, oid: c.oid, parents: c.parents.map(&:oid)}
  end
end

get '/commits' do
  commits = get_commits
  [200, {"Content-Type" => "application/json"}, commits.to_json]
end

get "/" do
  redirect "/index.html"
end
