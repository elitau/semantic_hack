require 'test_helper'

class TravelTest < ActiveSupport::TestCase
  class SampleQuery
    def query
      "select distinct ?Concept where {[] a ?Concept}"
    end
    
    def json_result
      %Q{
      { "head": { "link": [], "vars": ["Concept"] },
        "results": { "distinct": false, "ordered": true, "bindings": [
          { "Concept": { "type": "uri", "value": "http://www.openlinksw.com/schemas/virtrdf#QuadMapFormat" }},
          { "Concept": { "type": "uri", "value": "http://www.openlinksw.com/schemas/virtrdf#array-of-QuadMapFormat" }},
          { "Concept": { "type": "uri", "value": "http://www.openlinksw.com/schemas/virtrdf#QuadMap" }},
          { "Concept": { "type": "uri", "value": "http://www.openlinksw.com/schemas/virtrdf#QuadMapValue" }},
          { "Concept": { "type": "uri", "value": "http://www.openlinksw.com/schemas/virtrdf#array-of-QuadMapColumn" }},
          { "Concept": { "type": "uri", "value": "http://www.openlinksw.com/schemas/virtrdf#QuadMapColumn" }},
          { "Concept": { "type": "uri", "value": "http://www.openlinksw.com/schemas/virtrdf#array-of-QuadMapATable" }},
          { "Concept": { "type": "uri", "value": "http://www.openlinksw.com/schemas/virtrdf#QuadMapATable" }},
          { "Concept": { "type": "uri", "value": "http://www.openlinksw.com/schemas/virtrdf#QuadMapFText" }},
          { "Concept": { "type": "uri", "value": "http://www.openlinksw.com/schemas/virtrdf#array-of-string" }},
          { "Concept": { "type": "uri", "value": "http://www.openlinksw.com/schemas/virtrdf#QuadStorage" }},
          { "Concept": { "type": "uri", "value": "http://www.openlinksw.com/schemas/virtrdf#array-of-QuadMap" }},
          { "Concept": { "type": "uri", "value": "http://www.w3.org/1999/02/22-rdf-syntax-ns#Property" }},
          { "Concept": { "type": "uri", "value": "http://www.w3.org/2002/07/owl#Thing" }},
          { "Concept": { "type": "uri", "value": "http://www.w3.org/2002/07/owl#Class" }},
          { "Concept": { "type": "uri", "value": "http://www.w3.org/2002/07/owl#Ontology" }},
          { "Concept": { "type": "uri", "value": "http://www.w3.org/2000/01/rdf-schema#Class" }},
          { "Concept": { "type": "uri", "value": "http://www.w3.org/2002/07/owl#OntologyProperty" }},
          { "Concept": { "type": "uri", "value": "http://www.w3.org/2002/07/owl#AnnotationProperty" }},
          { "Concept": { "type": "uri", "value": "http://www.w3.org/1999/02/22-rdf-syntax-ns#List" }},
          { "Concept": { "type": "uri", "value": "http://www.w3.org/2002/07/owl#ObjectProperty" }},
          { "Concept": { "type": "uri", "value": "http://www.w3.org/2002/07/owl#DatatypeProperty" }},
          { "Concept": { "type": "uri", "value": "http://www.w3.org/2002/07/owl#FunctionalProperty" }},
          { "Concept": { "type": "uri", "value": "http://www.w3.org/2002/07/owl#InverseFunctionalProperty" }},
          { "Concept": { "type": "uri", "value": "http://localhost:8080/flickr/Place" }},
          { "Concept": { "type": "uri", "value": "http://www.w3.org/2000/01/rdf-schema#Datatype" }},
          { "Concept": { "type": "uri", "value": "http://localhost:8080/flickr/Image" }} ] } }
      }
    end
  end

  def test_should_return_json_result_from_sparql_query
    travel = Travel.new(:place => "stuttgart")
    query = SampleQuery.new
    result = travel.query_with_http_sparql_service(query.query)
    assert_equal JSON.parse(query.json_result), JSON.parse(result)
  end
  
 
end
