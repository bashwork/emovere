require 'hpricot'
require 'open-uri'
require 'logger'
require 'emovere/source'

module Emovere
module Source

  #
  # Picture finder for the Reuters Day in Pictures
  # collection
  #
  class ReutersImageSource < ImageSource
  
    @@root = "http://www.reuters.com"
    @logger = Logger.new(STDOUT)
  
    #
    # Find all the possible image sources from the current days
    # picture collection.
    #
    def find
      @logger.debug("searching in #{@@root}")
      sources = []
  
      begin
        doc = Hpricot(open("http://feeds.reuters.com/ReutersPictures"))
        doc.search("//item/link']").each do |link|
          source = link.inner_html.strip
          unless source.empty?
            sources << {
               :link    => source,
               :summary => :empty,
               :images  => find_images(source),
            }
          end
        end
      rescue Exception => ex
        @logger.error(ex)
      end
  
      sources
    end
  
    #
    # Find all the pictures in the |source| that pass the
    # stopper.check.
    #
    def find_images(source)
      @logger.debug("searching in #{source}")
      images = []
  
      begin
        # TODO they populate dynamically, figure it out
        # multimediaJSON
        images << {
            :image   => :empty,
            :summary => :empty,
            :source  => source_name,
        }
      rescue Exception => ex
        @logger.error(ex)
      end
  
      images
    end
  end
end
end
