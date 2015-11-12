require 'sinatra'
require 'redis'
require 'uri'

uri = URI.parse(ENV["REDIS4YOU_URL"])
redis = Redis.new(:host => uri.host, :port => uri.port, :password => uri.password)

helpers do
  include Rack::Utils
  alias_method :h, :escape_html

  def random_string(length)
    rand(36**length).to_s(36)
  end
end

get '/' do
  erb :index
end

post '/' do
  if params[:url] && !params[:url].empty?
    @shortcode = random_string 7
    redis.setnx "links:#{@shortcode}", params[:url]
  end
  erb :index
end

get '/:shortcode' do
  @url = redis.get "links:#{params[:shortcode]}"
  redirect @url || '/'
end
