#!/usr/bin/env /Users/ede/Documents/workspace/rails/semantic_hack/script/rails

def create_flickr_place_rdf(geoname, images)
  image_triples = images.map do |image|
    "<hasImage rdf:resource=\"#{image_id(image)}\"/>"
  end.join("\n        ")
  
  %Q{
    <owl:Thing rdf:about="#{geoname.place_id}">
        <rdf:type rdf:resource="Place"/>
        <hasName>#{escape_xml(geoname.name)}</hasName>
        <owl:sameAs rdf:resource="http://sws.geonames.org/#{geoname.geoname_id}/"/>
        #{image_triples}
    </owl:Thing>
  }
end

def image_id(image)
  "#{image.title.parameterize}-#{image.id}"
end

def create_flickr_image_rdf(geoname, images)
  images.map do |image|
    %Q{
      <Image rdf:about="#{image_id(image)}">
          <rdf:type rdf:resource="http://www.w3.org/2002/07/owl#Thing"/>
          <takenIn rdf:resource="#{geoname.place_id}"/>
          <hasName>#{escape_xml(image.title)}</hasName>
          <foaf:page rdf:resource="#{image.url}"/>
          <foaf:depiction rdf:resource="#{image.small_url}"/>
      </Image>
    }
  end.to_s
end


def escape_xml(input)
   # all kinds of other processing of input simulated by the input.dup
   result = input.dup

   result.gsub!(/[&<>'"]/) do | match |
     case match
     when '&' then return '&amp;'
     when '<' then return '&lt;'
     when '>' then return '&gt;'
     when "'" then return '&apos;'
     when '"' then return '&quote;'
     end
   end

   return result
end

def create_places_and_images
  all_places_rdf = ""
  all_images_rdf = ""
  places_rdf = ""
  images_rdf = ""
  
  found_images = 0
  geonames = Geoname.all
  # geonames = Geoname.find([4689, 20090, 6088, 19202, 4338, 7469, 4597, 653, 4550, 3966, 4589, 4771, 4446, 4215, 3983, 6, 16801, 16819, 5652, 3481, 6553, 18358, 19739, 19210, 20924, 19445, 19549, 19562, 20576, 20491])
  from = 0
  batch_size = 3000
  total_places = Geoname.count
  # total_places = 51
  times = total_places/batch_size + 1
  times.times do
    places_rdf = ""
    images_rdf = ""
    geonames[from, batch_size].compact.each do |geoname|
      images = FlickrGateway.search_for_geoname(geoname)
      found_images += images.size
      
      places_rdf += create_flickr_place_rdf(geoname, images)
      images_rdf += create_flickr_image_rdf(geoname, images)
      
      puts "#{geoname.id}: found #{images.size} images for #{geoname.name}" 
      puts "#{found_images} images found till now" if (geoname.id % 10 == 0)
    end
    write_rdf("places_#{from}-#{from+batch_size}.rdf", places_rdf)
    write_rdf("images_#{from}-#{from+batch_size}.rdf", images_rdf)
    all_places_rdf += places_rdf
    all_images_rdf += images_rdf
    
    from += batch_size
  end
  
  write_rdf("places_all.rdf", all_places_rdf)
  write_rdf("images_all.rdf", all_images_rdf)
  puts "totally #{found_images} images found"
end

def write_rdf(file_name, content)
  File.open(file_name, "w+") do |file|
    file.write rdf_head
    file.write content.to_s
    file.write rdf_footer
  end
end

def rdf_footer
  "</rdf:RDF>"
end

def rdf_head
  %Q{<?xml version="1.0"?>
     <!DOCTYPE rdf:RDF [
         <!ENTITY owl "http://www.w3.org/2002/07/owl#" >
         <!ENTITY xsd "http://www.w3.org/2001/XMLSchema#" >
         <!ENTITY owl2xml "http://www.w3.org/2006/12/owl2-xml#" >
         <!ENTITY rdfs "http://www.w3.org/2000/01/rdf-schema#" >
         <!ENTITY rdf "http://www.w3.org/1999/02/22-rdf-syntax-ns#" >
         <!ENTITY flickr "http://localhost:8080/flickr/" >
         <!ENTITY foaf "http://xmlns.com/foaf/0.1/" >
         <!ENTITY dbpo "http://dbpedia.org/ontology/" >
     ]>


     <rdf:RDF xmlns="http://localhost:8080/flickr/"
          xml:base="http://localhost:8080/flickr/"
          xmlns:flickr="http://localhost:8080/flickr/"
          xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"
          xmlns:owl2xml="http://www.w3.org/2006/12/owl2-xml#"
          xmlns:foaf="http://xmlns.com/foaf/0.1/"
          xmlns:owl="http://www.w3.org/2002/07/owl#"
          xmlns:xsd="http://www.w3.org/2001/XMLSchema#"
          xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
          xmlns:dbpo="http://dbpedia.org/ontology/">
         <owl:Ontology rdf:about=""/>
  }
end



create_places_and_images
