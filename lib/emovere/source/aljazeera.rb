require 'hpricot'
require 'open-uri'
require 'emovere/source'

module Emovere
module Source

  #
  # Picture finder for the Al Jazeera Day in Pictures
  # collection
  #
  class AlJazeeraImageSource < ImageSource
  
    @@root = "http://english.aljazeera.net"
  
    #
    # Find all the possible image sources from the current days
    # picture collection.
    #
    def find
      @@logger.debug("searching in #{@@root}")
      sources = []
  
      begin
        doc = Hpricot(open("#{@@root}/indepth/inpictures/"))
        doc.search("//table[@class='h89']").each do |story|
          summary = story.search("//div[@class='indexSummaryText']:first")
          source  = story.search("//a[@target='_parent']").first.attributes['href']
          sources << {
             :link    => source,
             :summary => summary.inner_html.strip.downcase,
             :images  => find_images(source),
          }
        end
      rescue Exception => ex
        @@logger.error(ex)
      end
  
      sources
    end
  
    #
    # Find all the pictures in the |source| that pass the
    # stopper.check.
    #
    def find_images(source)
      @@logger.debug("searching in #{@@root}#{source}")
      images = []
  
      begin
        doc = Hpricot(open(@@root + source))
        doc.search("//td[@class='DetailedSummary']//img").each do |image|
          images << {
              :image   => @@root + image.attributes['src'],
              :summary => :empty,
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
