class TravelsController < ApplicationController
  # GET /travels
  # GET /travels.xml
  # def index
  #   @travels = []#Travel.all
  # 
  #   respond_to do |format|
  #     format.html # index.html.erb
  #     format.xml  { render :xml => @travels }
  #   end
  # end

  # GET /travels/1
  # GET /travels/1.xml
  def show
    @travel = Travel.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @travel }
    end
  end

  # GET /travels/new
  # GET /travels/new.xml
  def new
    @travel = Travel.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @travel }
    end
  end

  # GET /travels/1/edit
  def edit
    @travel = Travel.find(params[:id])
  end

  # POST /travels
  # POST /travels.xml
  def show_results
    @travel = Travel.new(params)

    respond_to do |format|
      if @travel.search
        format.html #{ redirect_to(@travel, :notice => 'Travel was successfully created.') }
        format.xml  { render :xml => @travel, :status => :created, :location => @travel }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @travel.errors, :status => :unprocessable_entity }
      end
    end
  end

end
