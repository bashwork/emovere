require 'sinatra/base'
require 'sinatra/jsonp'
require 'emovere'
require 'haml'

class EmovereApp < Sinatra::Base
  #
  # configuration
  #
  configure(:production, :development) do
    set :root, File.dirname(__FILE__)
    set :indicators, settings.root + "/config/indicators"
    set :public_folder, settings.root + "/public"
    set :views, settings.root + "/views"
    set :logging, true
    set :static, true
  end

  #
  # Initialize our manager, I am sure there is a better way
  # to do this.
  #
  @@manager = Emovere::EmovereManager.new(settings.indicators)
  
  #
  # cache and update our manager when we get the chance
  #
  before do 
    cache_control :public, :max_age => 3600
#    @@manager.update
  end

  #
  # helpers
  #
  helpers Sinatra::Jsonp
  
  #
  # people can play with the viewer
  #
  get '/' do
    haml :index
  end

  #
  # people can play with the api
  #
  get '/api/source/?' do
    jsonp @@manager.sources
  end

  get '/api/images/:category/?' do
    jsonp @@manager.images(params[:category])
  end

  get '/api/images/:category/:grade/?' do
    jsonp @@manager.images(params[:category], params[:grade].to_i)
  end
  
  get '/api/category/?' do
    jsonp @@manager.categories
  end
  
  post '/api/category/check' do
    jsonp @@manager.check(params[:data])
  end
  
  post '/api/category/grade' do
    jsonp @@manager.grade(params[:data])
  end
  
  #
  # or they can just go home
  #
  not_found do
    redirect to('/')
  end

  run! if app_file == $0

end
