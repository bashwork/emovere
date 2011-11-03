require 'hpricot'
require 'open-uri'
require 'emovere/source'

module Emovere
module Source

  #
  # Picture finder for the Telegraph Day in Pictures
  # collection
  #
  class TelegraphImageSource < ImageSource
  
    @@root = "http://www.telegraph.co.uk"
  
    #
    # Find all the possible image sources from the current days
    # picture collection.
    #
    def find
      @@logger.debug("searching in #{@@root}")
      sources = []
  
      begin
        doc = Hpricot(open("#{@@root}/news/picturegalleries/picturesoftheday/rss"))
        doc.search("/rss/channel/item']").each do |story|
          summary = story.search("description")
          unless summary.empty? # I don't know how this fucking happens
            sources << {
                :link    => story.search("guid").inner_html,
                :summary => summary.first.to_plain_text.downcase,
                :images  => find_images(story),
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
    # stopper.check.
    #
    def find_images(doc)
      source = doc.search("guid").inner_html
      @@logger.debug("searching in #{source}")
      images = []
  
      #begin
      #  doc.search("media:content").each do |image|
      #    images << {
      #        :image   => image.attributes['url'],
      #        :summary => image.search("media:description").inner_html.strip,
      #        :source  => source_name,
      #    }
      #  end
      #rescue Exception => ex
      #  @@logger.error(ex)
      #end
  
      images
    end
  end
end
end
