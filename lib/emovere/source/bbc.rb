require 'hpricot'
require 'open-uri'
require 'logger'
require 'emovere/source'

module Emovere
module Source

  #
  # Picture finder for the BBC Day in Pictures collection
  #
  class BBCImageSource < ImageSource
  
    @@root = "http://bbc.co.uk"
    @@logger = Logger.new(STDOUT)
  
    #
    # Find all the possible image sources from the current days
    # picture collection.
    #
    def find
      @@logger.debug("searching in #{@@root}")
      sources = [] # we take all sources for the day
  
      begin
        doc = Hpricot(open("http://feeds.bbci.co.uk/news/in_pictures/rss.xml"))
        doc.search("//item/guid']").each do |link|
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
        @@logger.error(ex)
      end
  
      sources
    end
  
    #
    # Find all the pictures in the |source| that pass the
    # category check.
    #
    def find_images(source)
      @@logger.debug("searching in #{source}")
      images = []
  
      begin
        doc = Hpricot(open(source))
        doc.search("//div[@id='pictureGallery']//li").each do |image|
          summary = image.search("//span:first").inner_html.strip
          image   = image.search("//a:first").first.attributes['href']
          images << {
              :image   => image,
              :summary => summary.downcase,
              :source  => source_name,
          }
        end
      rescue Exception => ex
        @@logger.error(ex)
      end
  
      images
    end
  end
end
end
