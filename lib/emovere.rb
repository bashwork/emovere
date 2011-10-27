require 'thread'
require 'emovere/version'
require 'emovere/source'
require 'emovere/category'

module Emovere

  class EmovereManager

    def initialize(path)
      @cache      = {}
      @thread     = nil
      @mutex      = Mutex.new
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
      return [] if !@cache.include? category.to_sym
      return @cache[category.to_sym].select { |image| image[:grade] >= grade }
    end

    # ------------------------------------------------------------
    # update logic
    # ------------------------------------------------------------

    #
    # Perform a background update of the image cache
    #
    def update
      return if @thread != nil

      @thread = Thread.new {
        while true do
          refreshed = get_current_images
          @mutex.synchronize { @cache = refreshed }
          sleep (60 * 60 * 24)
        end
      }
    end

    private

    #
    # Retrieve and parse the current days images
    #
    def get_current_images
        cache   = {}
        sources = @sources.find
        @categories.categories.each { |key, category|
          cache[key] = sources.flat_map { |source|
            summary  = category.grade(source[:summary])
            images   = source[:images].map { |image| {
                :link   => image[:image],
                :source => image[:source],
                :grade  => summary + category.grade(image[:summary])
            }}.select { |image| image[:grade] > 0}
            images
          }
        }
        cache
    end
  end

end

