require 'emovere/version'
require 'emovere/source'
require 'emovere/category'

module Emovere

  class Something

    def initialize(path)
      @cache      = {}
      @sources    = SourceManager.new()
      @categories = CategoryManager.new(path)
    end

    # ------------------------------------------------------------
    # views for the api 
    # ------------------------------------------------------------

    def sources
      @sources.names
    end

    def categories
      @categories.names
    end

    def check(request)
      @categories.check request
    end

    def grade(request)
      @categories.grade request
    end

    def images(category, grade=1)
      return [] if !cache.include? category.to_sym
      return cache[category].select { |image| image[:grade] >= grade }
    end

    #
    # Perform a background update of the image cache
    #
    def update
      cache   = {}
      sources = @sources.find
      @categories.each { |key, category|
        cache[key] = sources.flat_map { |source|
          summary  = category.grade(source[:summary])
          images   = source[:images].map { |image| {
              :link   => image[:link],
              :source => image[:source],
              :grade  => summary + category.grade(image[:summary])
          }}
          images
        }
      }
      @cache = cache # todo lock
    end
  end

end
