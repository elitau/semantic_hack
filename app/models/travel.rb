class Travel

  attr_reader :place, :time, :images, :result, :query, :raw_json_result, :place_name
  
  def initialize(params = {})
    @place = params[:place] or params[:id]
    @time = params.delete(:time)
  end
  
  def search
    Rails.logger.error "Executing SPARQL Query: \n#{query}"
    uri = URI.parse("http://localhost:8890/sparql")
    @raw_json_result = query_with_http_sparql_service(query, uri)
    # @raw_json_result = execute_command(query)
    Rails.logger.error "Query result: \n#{raw_json_result}"
    processed_result = process_result(raw_json_result)
    extract_images(processed_result)
    # extract_abstract(processed_result)
    self
  end
  
  def place_id
    if geoname
      @place_name = geoname.name
      return geoname.place_id
    else
      return nil
    end
  end
  
  def extract_abstract(processed_result)
    @abstract = processed_result["results"]["bindings"].first["comment"]["value"]
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
  
  def abstract
    @abstract ||= geoname ? query_abstract_from_dbpedia(geoname) : nil
  end
  
  def geoname
    @geoname ||= @place and Geoname.where("name LIKE ?", "#{@place}").first
  end
  
  def query_abstract_from_dbpedia(geoname)
    uri = URI.parse("http://dbpedia.org/sparql")
    query = "SELECT DISTINCT *
     WHERE {
       ?s owl:sameAs <#{geoname.resource_url}> .
       ?s rdfs:comment ?comment .
     	 FILTER langMatches( lang(?comment), 'en') .
    }"
    json = JSON.parse(query_with_http_sparql_service(query, uri))
    extract_abstract json
  end
  
  def process_result(raw_json_result)
    @result = JSON.parse(raw_json_result)
  end
  
  def execute_command(query)
    command = "#{NG4J_EXECUTABLE_PATH} -sparql \"#{query}\" -maxsteps 6 -resultfmt JSON"
    Rails.logger.info "========================================="
    Rails.logger.info "Executing command on console: #{command}"
    Rails.logger.info "========================================="
    `#{command}`
  end
  
  def query_with_http_sparql_service(query, uri)
    res = Net::HTTP.post_form(uri, 'query' => query, 'format' => "application/sparql-results+json")
    res.body
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
