$: << "../lib"
require 'sinatra/base'
require 'sinatra/contrib'
require 'emovere'

class EmovereApp < Sinatra::Base
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

  @@manager = Emovere::EmovereManager.new("../config/indicators")
  
  before do 
    cache_control :public, :max_age => 60
    @@manager.update
  end

  #
  # helpers
  #
  helpers Sinatra::JSON
  
  #
  # people can play with the viewer
  #
  get '/' do
    "hello world"
  end

  #
  # people can play with the api
  #
  get '/api/source/?' do
    json @@manager.sources
  end

  get '/api/images/:category/?' do
    json @@manager.images params[:category]
  end

  get '/api/images/:category/:grade/?' do
    json @@manager.images(params[:category], params[:grade].to_i)
  end
  
  get '/api/category/?' do
    json @@manager.categories
  end
  
  post '/api/category/check' do
    json @@manager.check params[:data]
  end
  
  post '/api/category/grade' do
    json @@manager.grade params[:data]
  end
  
  #
  # or they can just go home
  #
  not_found do
    redirect to('/')
  end

  run! if app_file == $0

end
