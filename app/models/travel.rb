class Travel

  attr_reader :place, :time, :abstract, :images, :result, :query, :raw_result, :place_name, :geoname
  
  def initialize(params = {})
    @place = params[:place] or params["place"]
    @time = params.delete(:time)
  end
  
  def search
    Rails.logger.error "Executing SPARQL Query: \n#{query}"
    command = "#{NG4J_EXECUTABLE_PATH} -sparql \"#{query}\" -maxsteps 6 -resultfmt JSON"
    @raw_result = execute_command(command)
    Rails.logger.error "Query result: \n#{raw_result}"
    processed_result = process_result(raw_result)
    extract_images(processed_result)
    extract_abstract(processed_result)
    self
  end
  
  def place_id
    @geoname = Geoname.where("name LIKE ?", "%#{@place}%").first
    if @geoname
      @place_name = @geoname.name
      return @geoname.place_id
    else
      return nil
    end
  end
  
  def extract_abstract(processed_result)
    @abstract = processed_result["results"]["bindings"].first["abstract"]["value"]
  rescue NoMethodError
    return nil
  end
  
  def extract_images(processed_result)
    @images = processed_result["results"]["bindings"].map do |hash_image|
      Photo.new(
        :title => hash_image["image_title"]["value"],
        :thumbnail_url => hash_image["depiction"]["value"],
        :url => hash_image["image"]["value"]
      )
    end
  end
  
  def process_result(raw_result)
    @result = JSON.parse(raw_result)
  end
  
  def execute_command(command)
    `#{command}`
  end
  
  def query
    @query ||= namespaces_for_query + select_part_of_query
  end
  
  def select_part_of_query
    "SELECT DISTINCT *
     WHERE {
       flickr:#{place_id} flickr:hasImage ?image .
     	 ?image flickr:hasName ?image_title .
     	 ?image foaf:depiction ?depiction .
     	 flickr:#{place_id} owl:sameAs ?other_place .
     	 OPTIONAL { 
     	 	?other_place owl:sameAs ?third_place .
     	 	?third_place dbpp:abstract ?abstract .
    		FILTER langMatches( lang(?abstract), 'en')
     	 }
    }"
  end
  
  def namespaces_for_query
    "PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#> 
     PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#> 
     PREFIX owl: <http://www.w3.org/2002/07/owl#> 
     PREFIX dbpp: <http://dbpedia.org/property/> 
     PREFIX dbpo: <http://dbpedia.org/ontology/> 
     PREFIX dbpr: <http://dbpedia.org/resource/> 
     PREFIX foaf: <http://xmlns.com/foaf/0.1/>
     PREFIX flickr: <http://localhost:8080/flickr/>\n"
  end
  
  
end
