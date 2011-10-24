require 'sinatra/base'
require 'sinatra/contrib'
require './category'

class Emovere < Sinatra::Base
  #
  # configuration
  #
  configure(:production, :development) do
    set :public_folder, File.dirname(__FILE__) + '/static'
    set :views, "views"
    set :logging, true
    set :static, true
    set :root, File.dirname(__FILE__)
  end
  
  before do 
    cache_control :public, :max_age => 60
  end

  @@categories = CategoryManager.new()

  #
  # helpers
  #
  # helpers Sinatra::Json
  helpers do
  end
  
  #
  # people can play with the viewer
  #
  get '/' do
    "hello world"
  end

  #
  # people can play with the api
  #
  get '/api/sources/' do
    json @@categories.sources
  end

  get '/api/images/:category' do
    json @@categories.grade
  end
  
  get '/api/category' do
    json @@categories.available
  end
  
  post '/api/category/check' do
    json @@categories.check params[:data]
  end
  
  post '/api/category/grade' do
    json @@categories.grade params[:data]
  end
  
  #
  # or they can just go home
  #
  not_found do
    redirect to('/')
  end

end
