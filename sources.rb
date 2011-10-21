require 'hpricot'
require 'open-uri'

#
#
#
class ImageFinder

  #
  # Initialize an impage finder with the specfied
  # |sources|.
  #
  def initialize(sources=nil)
    @sources = sources
  end

  #
  # Save all the supplied images that were found to the
  # specified |path|.
  #
  def find_and_save(category, path=".")
    File.directory?(path) || Dir.mkdir(path)
    find(category).each do |image|
      puts "Saving #{image}"
      open(File.join(path, image.split('/').last), "wb") { |file|
        file.write(open(image).read)
      }
    end
  end

  #
  # Save all the supplied images that were found to the
  # specified |path|.
  #
  def find(category)
    @sources.flat_map { |source| source.find category }
  end

end

#
# Base class for a source to find pictures for a specific purpose
#
class ImageSource

  #
  # Initialize a new image source to search in the
  # supplied |category|
  #
  def initialize(category)
    @category = category
  end

  #
  # Find picturers that match the supplied stop word list.
  #
  def find(category)
    find_sources.flat_map { |source| find_images source }
  end

  def find_sources
    raise "Method not implemented"
  end

  def find_images(source)
    raise "Method not implemented"
  end

end


#
# Picture finder for the BBC Day in Pictures collection
#
class BBCImageSource < ImageSource

  @@root = "http://bbc.co.uk"

  #
  # Find all the possible image sources from the current days
  # picture collection.
  #
  def find_sources
    puts "searching in #{@@root}"
    links = [] # we take all sources for the day
    count = 0

    begin
      doc = Hpricot(open("http://feeds.bbci.co.uk/news/in_pictures/rss.xml"))
      doc.search("//item/guid']").each do |link|
        value = link.inner_html.strip
        links << value unless value.empty?
      end
    rescue Exception => ex
      puts ex
    end

    links
  end

  #def find_frontpage_sources
  #  puts "searching in #{@@root}"
  #  links = [] # we take all sources for the day

  #  begin
  #    doc = Hpricot(open("#{@@root}/news/in_pictures/"))
  #    doc.search("//div[@class='guide']//a[@class='story']").each do |link|
  #      links << link.attributes['href']
  #    end
  #  rescue Exception => ex
  #    puts ex
  #  end

  #  links
  #end

  #
  # Find all the pictures in the |source| that pass the
  # category check.
  #
  def find_images(source)
    puts "searching in #{source}"
    images = []

    begin
      doc = Hpricot(open(source))
      doc.search("//div[@id='pictureGallery']//li").each do |image|
        summary = image.search("//span:first")
        if @category.check(summary.inner_html.strip)
          images << image.search("//a:first").first.attributes['href']
        end 
      end
    rescue Exception => ex
      puts ex
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
  def find_sources
    puts "searching in #{@@root}"
    links = []

    begin
      doc = Hpricot(open("#{@@root}/indepth/inpictures/"))
      doc.search("//table[@class='h89']").each do |story|
        summary = story.search("//div[@class='indexSummaryText']:first")
        if @category.check(summary.inner_html.strip)
          link = story.search("//a[@target='_parent']").first
          links << link.attributes['href']
        end
      end
    rescue Exception => ex
      puts ex
    end

    links
  end

  #
  # Find all the pictures in the |source| that pass the
  # stopper.check.
  #
  def find_images(source)
    puts "searching in #{source}"
    images = []

    begin
      doc = Hpricot(open(@@root + source))
      doc.search("//td[@class='DetailedSummary']//img").each do |image|
        images << @@root + image.attributes['src']
      end
    rescue Exception => ex
      puts ex
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
  def find_sources
    puts "searching in #{@@root}"
    links = []

    begin
      doc = Hpricot(open("http://feeds.reuters.com/ReutersPictures"))
      doc.search("//item/link']").each do |link|
        value = link.inner_html.strip
        links << value unless value.empty?
      end
    rescue Exception => ex
      puts ex
    end

    links
  end

  #
  # Find all the pictures in the |source| that pass the
  # stopper.check.
  #
  def find_images(source)
    puts "searching in #{source}"
    images = []

    # TODO they populate dynamically, figure it out
    # multimediaJSON

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
  def find_sources
    puts "searching in #{@@root}"
    links = []

    begin
      doc = Hpricot(open("#{@@root}/world/world+content/gallery/rss"))
      doc.search("//item']").each do |story|
        summary = story.search("//description")
        if @category.check(summary.inner_html.strip)
          link = story.search("//guid").first.inner_html.strip
          links << link unless link.empty?
        end
      end
    rescue Exception => ex
      puts ex
    end

    links
  end

  #
  # Find all the pictures in the |source| that pass the
  # stopper.check.
  #
  def find_images(source)
    puts "searching in #{source}"
    images = []

    begin
      doc = Hpricot(open(source))
      doc.search("//div[@class='gio carousel']//img").each do |image|
        piece = image.attributes['src'].split('-thumb').first
        images << piece + ".jpg"
      end
    rescue Exception => ex
      puts ex
    end

    images
  end

end
