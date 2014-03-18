require 'rubygems'
require 'bundler/setup'

require 'sinatra'
require 'json'
require 'yaml'
require 'rugged'

configure :development, :production do
  enable :logging
end

CONFIG = YAML.load(File.read 'config/config.yml')

def range_spec
  (params["range"].nil? || params["range"].empty?) ? nil : params["range"]
end

def range_ref repo
  return nil unless range_spec
  repo.references[range_spec]
rescue Rugged::ReferenceError => e
  puts "#{range_spec} not found"
  halt 404
end

def to_commit obj
  if obj.is_a? Rugged::Commit
    return obj
  elsif obj.respond_to? :target
    to_commit obj.target
  else
    nil
  end
end

def get_commits
  repo = Rugged::Repository.new CONFIG['repository_path']

  range = to_commit(range_ref(repo) || repo.head)

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
