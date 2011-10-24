require 'yaml'
require 'logger'

module Emovere
  #
  # Used to check if a given datasource matches a given
  # category's indicators.
  #
  class Category
  
    #
    # Initializes a new |category| checker given the supplied
    # list of |indicator| words.
    #
    def initialize(category, indicator=nil)
      @category = category
      @indicator = indicator
    end
  
    #
    # Check if the supplied |string| matches any targeted words
    #
    def check(string)
      string.split.any? { |word| @indicator.include? word }
    end
  
    #
    # Give the supplied |string| a grade for this category
    #
    def grade(string)
      weight = 0
      string.split.each { |word|
          (@indicator.include? word) && weight += 1
      }
      weight
    end
  end
  
  #
  # A manager for all the available categories
  #
  class CategoryManager
  
    @logger = Logger.new(STDOUT)

    #
    # Initializes a new collection of categories using
    # the indicator words at the given |path|.
    #
    def initialize(path='../../config/indicators')
      @categories = {}
      Dir.entries(path).each do |file|
        unless ['.', '..'].include? file
          category = file.split('-').first.intern
          indicators = YAML::load_file(File.join(path, file))
          @logger.debug("Loading #{category} indicators")
          @categories[category] = Category.new(category, indicators)
        end
      end
    end
  
    #
    # Return the currently available categories
    #
    def available
      @categories.keys
    end
  
    #
    # Check if the supplied |string| is in the specified
    # |category|.
    #
    def check(string, category)
      @categories.key?(category) &&
      @categories[category].check(string.downcase)
    end
  
    #
    # Check if the supplied |string| is in any of the categories.
    #
    def check(string)
      @categories.select { |key,category|
          category.check(string.downcase)
      }.keys
    end
  
    #
    # Give the supplied |string| a grade for all the
    # categories
    #
    def grade(string)
      result = {}
      @categories.each { |key,category|
          result[key] = category.grade(string.downcase)
      }
      result
    end
  end

end
