require 'sinatra'
require 'json'
require 'yaml'
require 'rugged'

CONFIG = YAML.load(File.read 'config/config.yml')

def get_commits
  repo = Rugged::Repository.new CONFIG['repository_path']
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
