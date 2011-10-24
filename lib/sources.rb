require 'hpricot'
require 'open-uri'
require 'logger'

# ------------------------------------------------------------
# logging configuration
# ------------------------------------------------------------
$logger = Logger.new(STDOUT)

# ------------------------------------------------------------
# manager classes
# ------------------------------------------------------------
#
# A manager for the various image sources
#
class SourceManager

  #
  # Initialize an impage finder with the specfied
  # |sources|.
  #
  def initialize(sources=nil)
    @sources = sources || Hash[ImageSource.registered
        .map {|name,source| [name, source.new()] }]
    $logger.info("initialied with sources: #{@sources.keys}")
  end

  #
  # find images from all the available sources and
  # return them as a hash.
  #
  def find
    @sources.flat_map { |name, source| source.find }
  end

  def sources
    @sources.keys
  end

end

#
# Base class for a source to find pictures for a specific purpose
#
class ImageSource

  @@registry = {}

  #
  # Register images sources to the manager
  #
  def self.inherited(klass)
    name = klass.to_s.split('Image').first.downcase.to_sym
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
    find.each do |image|
      $logger.debug("Saving #{image[:image]}")
      open(File.join(path, image[:image].split('/').last), "wb") { |file|
        file.write(open(image[:image]).read)
      }
    end
  end

end

# ------------------------------------------------------------
# image sources (split into own files)
# ------------------------------------------------------------

#
# Picture finder for the BBC Day in Pictures collection
#
class BBCImageSource < ImageSource

  @@root = "http://bbc.co.uk"

  #
  # Find all the possible image sources from the current days
  # picture collection.
  #
  def find
    $logger.debug("searching in #{@@root}")
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
      $logger.error(ex)
    end

    sources
  end

  #
  # Find all the pictures in the |source| that pass the
  # category check.
  #
  def find_images(source)
    $logger.debug("searching in #{source}")
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
      $logger.error(ex)
    end

    images
  end

end


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
    $logger.debug("searching in #{@@root}")
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
      $logger.error(ex)
    end

    sources
  end

  #
  # Find all the pictures in the |source| that pass the
  # stopper.check.
  #
  def find_images(source)
    $logger.debug("searching in #{source}")
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
      $logger.error(ex)
    end

    images
  end

end


#
# Picture finder for the Reuters Day in Pictures
# collection
#
class ReutersImageSource < ImageSource

  @@root = "http://www.reuters.com"

  #
  # Find all the possible image sources from the current days
  # picture collection.
  #
  def find
    $logger.debug("searching in #{@@root}")
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
      $logger.error(ex)
    end

    sources
  end

  #
  # Find all the pictures in the |source| that pass the
  # stopper.check.
  #
  def find_images(source)
    $logger.debug("searching in #{source}")
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
      $logger.error(ex)
    end

    images
  end

end


#
# Picture finder for the Guardian Day in Pictures
# collection
#
class GuardianImageSource < ImageSource

  @@root = "http://www.guardian.co.uk"

  #
  # Find all the possible image sources from the current days
  # picture collection.
  #
  def find
    $logger.debug("searching in #{@@root}")
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
      $logger.error(ex)
    end

    sources
  end

  #
  # Find all the pictures in the |source| that pass the
  # stopper.check.
  #
  def find_images(source)
    $logger.debug("searching in #{source}")
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
      $logger.error(ex)
    end

    images
  end

end
