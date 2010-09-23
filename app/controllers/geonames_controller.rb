class GeonamesController < ApplicationController
  # GET /travels
  # GET /travels.xml
  def index
    @geonames = Geoname.paginate :page => params[:page], :order => 'name'
  
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @travels }
    end
  end
  
end
