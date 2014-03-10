require 'sinatra'
require 'json'
require 'yaml'
require 'rugged'

CONFIG = YAML.load(File.read 'config/config.yml')

def range_spec
  (params["range"].nil? || params["range"].empty?) ? nil : params["range"]
end

def get_commits
  repo = Rugged::Repository.new CONFIG['repository_path']
  range = range_spec || repo.head.target
  walker = Rugged::Walker.new(repo)
  walker.push(range)
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
