require 'sinatra'
require 'sinatra/contrib'
require './category'

# ------------------------------------------------------------ 
# configuration
# ------------------------------------------------------------ 
configure do
  set :public_folder, File.dirname(__FILE__) + '/static'
  set :views, "views"
  set :logging, true
end

before do 
  cache_control :public, :max_age => 60
end


# ------------------------------------------------------------ 
# helpers
# ------------------------------------------------------------ 
# helpers Sinatra::Json
helpers do
 # format
end

# ------------------------------------------------------------ 
# routes
# ------------------------------------------------------------ 
categories = CategoryManager.new()

#
# people can play with the viewer
#
get '/' do
  "hello world"
end

#
# people can play with the api
#
get '/api/images/:category' do
  #params[:format]
  json categories.grade
end

get '/api/category' do
  #params[:format]
  json categories.available
end

post '/api/category/check' do
  json categories.check params[:data]
end

post '/api/category/grade' do
  json categories.grade params[:data]
end

#
# or they can just go home
#
not_found do
  redirect to('/')
end
