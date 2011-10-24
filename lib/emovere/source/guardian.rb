require 'hpricot'
require 'open-uri'
require 'logger'
require 'emovere/source'

module Emovere
module Source

  #
  # Picture finder for the Guardian Day in Pictures
  # collection
  #
  class GuardianImageSource < ImageSource
  
    @@root = "http://www.guardian.co.uk"
    @logger = Logger.new(STDOUT)
  
    #
    # Find all the possible image sources from the current days
    # picture collection.
    #
    def find
      @logger.debug("searching in #{@@root}")
      sources = []
  
      begin
        doc = Hpricot(open("#{@@root}/world/world+content/gallery/rss"))
        doc.search("//item']").each do |story|
          summary = story.search("//description").inner_html.strip
          source = story.search("//guid").first.inner_html.strip
          unless source.empty?
            sources << {
                :link    => source,
                :summary => summary.downcase,
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
        doc = Hpricot(open(source))
        doc.search("//div[@class='gio carousel']//img").each do |image|
          piece = image.attributes['src'].split('-thumb').first
          images << {
              :image   => piece + ".jpg",
              :summary => :empty,
              :source  => source_name,
          }
        end
      rescue Exception => ex
        @logger.error(ex)
      end
  
      images
    end
  end
end
end
