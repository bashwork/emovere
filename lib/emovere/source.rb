require 'hpricot'
require 'open-uri'
require 'logger'

module Emovere

  #
  # A manager for the various image sources
  #
  class SourceManager
  
    attr_reader :names

    #
    # Initialize an impage finder with the specfied
    # |sources|.
    #
    def initialize(sources=nil)
      @logger = Logger.new(STDOUT)
      @sources = sources || Hash[ImageSource.registered
          .map {|name,source| [name, source.new()] }]
      @names = @sources.keys
      @logger.info("initialied with sources: #{@names}")
    end
  
    #
    # find images from all the available sources and
    # return them as a hash.
    #
    def find
      @logger.info("searching in sources: #{@names}")
      @sources.flat_map { |name, source| source.find }
      #File.open("/tmp/images.yaml", "r") do |file|
      #  return YAML::load(file)
      #end
    end

    #
    # find images from all the available sources and
    # return them as a hash.
    #
    def find_and_save(path='.')
      @logger.info("searching in sources: #{@names}")
      @sources.flat_map { |name, source| source.find_and_save(path) }
    end
  end
  
  #
  # Base class for a source to find pictures for a specific purpose
  #
  class ImageSource
  
    @@registry = {}
    @@logger = Logger.new(STDOUT)
  
    #
    # Register images sources to the manager
    #
    def self.inherited(klass)
      name = klass.to_s.split('Image').first.downcase
      name = name.split('::').last.to_sym
      send :define_method, :source_name do
        name
      end
      @@registry[name] = klass
    end
  
    def self.registered
      @@registry
    end
  
    #
    # Find available picturers that can be later processed
    # for matches.
    #
    def find
      raise "Method not implemented"
    end
  
    #
    # Save all the supplied images that were found to the
    # specified |path|.
    #
    def find_and_save(path=".")
      File.directory?(path) || Dir.mkdir(path)
      find.each do |source|
        source[:images].each do |image|
          @@logger.debug("Saving #{image[:image]}")
          open(File.join(path, image[:image].split('/').last), "wb") { |file|
            file.write(open(image[:image]).read)
          }
        end
      end
    end
  end

end

require 'emovere/source/bbc'
require 'emovere/source/aljazeera'
require 'emovere/source/reuters'
require 'emovere/source/guardian'
