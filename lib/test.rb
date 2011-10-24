#require './category'
#require './sources'

#category = Category.new(:violent, YAML::load_file('indicators/violent-indicators'))
#finder   = ImageFinder.new([GuardianImageSource.new(category)])
##finder   = ImageFinder.new([BBCImageSource.new(category)])
#finder.find_and_save(category, "violent")

value = '     '
unless (x = value.strip).empty?
  puts x
end

value = '  r  '
unless (x = value.strip).empty?
  puts x
end
