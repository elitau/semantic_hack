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
  
  def extract_value(processed_result, value_name)
    processed_result["results"]["bindings"].first[value_name]["value"]
  rescue NoMethodError
    return nil
  end
  
  def extract_images(processed_result)
    @images = processed_result["results"]["bindings"].map do |hash_image|
      Photo.new(
        :title => hash_image["image_title"]["value"],
        :thumbnail_url => hash_image["depiction"]["value"],
        :url => hash_image["page"]["value"]
      )
    end
  end

  def geoname
    @geoname ||= if @place
      name = Geoname.where("name LIKE ?", "#{@place}").first
      name = Geoname.where("name LIKE ?", "%#{@place}%").first unless name
      name
    end
    
  end
  # 
  # DBPEDIA_PROPERTIES = {
  #   'population_total' => 'dbpo:populationTotal',
  #   'region'           => 'dbpo:region',
  #   'wikipedia_link'   => 'foaf:page',
  #   'homepage_of_city' => 'foaf:homepage',
  #   'abstract'         => 'rdfs:comment',
  #   'region_name'      => 'rdfs:comment',
  #   'thumbnail_url'    => 'foaf:depiction'
  # }
  class Triple
    attr_reader :subjekt, :praedikat, :objekt, :create_method
    def initialize(subjekt, praedikat, objekt, create_method = true)
      @subjekt = subjekt
      @praedikat = praedikat
      @objekt = objekt
      @create_method = create_method
    end
  end
  
  DBPEDIA_PROPERTIES = [
    Triple.new('?o', 'dbpo:populationTotal' , 'population_total'),
    Triple.new('?o', 'foaf:page'            , 'wikipedia_link'  ),
    Triple.new('?o', 'foaf:homepage'        , 'homepage_of_city'),
    # Triple.new('?o', 'dbpo:region'          , 'r'                , false),
    # Triple.new('?r', 'rdfs:comment'         , 'region_name'     ),
    Triple.new('?o', 'rdfs:comment'         , 'abstract'        ),
    Triple.new('?o', 'foaf:depiction'       , 'thumbnail_url'   ),
  ]
  
  def dbpedia_properties
    DBPEDIA_PROPERTIES.map{|triple| "OPTIONAL {#{triple.subjekt} #{triple.praedikat} ?#{triple.objekt} .\n}"}
  end
  
  DBPEDIA_PROPERTIES.each do |triple|
    define_method(triple.objekt) do
      extract_value(query_data_from_dbpedia, triple.objekt)
    end if triple.create_method
  end
  
  def query_data_from_dbpedia
    @dbpedia_json ||= geoname and begin
      uri = URI.parse("http://dbpedia.org/sparql")
      JSON.parse(query_with_http_sparql_service(namespaces_for_query + dbpedia_query, uri))
    end
  end
  
  def dbpedia_query
    "SELECT DISTINCT *
     WHERE {
       ?o owl:sameAs <#{geoname.resource_url}> .
       #{dbpedia_properties} FILTER langMatches( lang(?abstract), 'en') .
    }"
  end
  
  def process_result(raw_json_result)
    @result = JSON.parse(raw_json_result)
  end
  
  # def execute_command(query)
  #   command = "#{NG4J_EXECUTABLE_PATH} -sparql \"#{query}\" -maxsteps 6 -resultfmt JSON"
  #   Rails.logger.info "========================================="
  #   Rails.logger.info "Executing command on console: #{command}"
  #   Rails.logger.info "========================================="
  #   `#{command}`
  # end
  
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
     	 ?image foaf:page ?page .
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
