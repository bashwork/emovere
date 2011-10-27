require 'yaml'
require 'logger'

module Emovere
  #
  # Used to check if a given datasource matches a given
  # category's indicators.
  #
  class Category
  
    attr_reader :category

    #
    # Initializes a new |category| checker given the supplied
    # list of |indicator| words.
    #
    def initialize(category, indicator=nil)
      @category  = category
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
      return   0 if (string == :empty)
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
  
    attr_reader :names
    attr_reader :categories

    #
    # Initializes a new collection of categories using
    # the indicator words at the given |path|.
    #
    def initialize(path='../../config/indicators')
      @logger = Logger.new(STDOUT)
      @categories = {}
      Dir.entries(path).each do |file|
        unless ['.', '..'].include? file
          category = file.split('-').first.intern
          indicators = YAML::load_file(File.join(path, file))
          @logger.debug("Loading #{category} indicators")
          @categories[category] = Category.new(category, indicators)
        end
      end
      @names = @categories.keys
    end
  
    #
    # Check if the supplied |string| is in the specified
    # |category|.
    #
    def check(string, category)
      @categories.key?(category) &&
      @categories[category].check(string)
    end
  
    #
    # Check if the supplied |string| is in any of the categories.
    #
    def check(string)
      @categories.select { |key,category|
          category.check(string)
      }.keys
    end
  
    #
    # Give the supplied |string| a grade for all the
    # categories
    #
    def grade(string)
      result = {}
      @categories.each { |key,category|
          result[key] = category.grade(string)
      }
      result
    end
  end

end
