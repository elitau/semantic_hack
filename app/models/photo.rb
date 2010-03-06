class Photo
  attr_reader :thumbnail_url, :title, :url
  
  def initialize(attributes = {})
    @thumbnail_url = attributes[:thumbnail_url]
    @title = attributes[:title]
    @url = attributes[:url]
  end
  
  
end