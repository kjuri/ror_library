class AuthorsController < ApplicationController
  before_action :set_author, only: [:show, :edit, :update, :destroy]
  before_action :authenticate_user!, except: [:index, :show]
  before_filter :set_search

  # GET /authors
  # GET /authors.json
  def index
    @q = Author.search(params[:q])
    @authors = @q.result(distinct: true).paginate(:page => params[:page]).order('last_name ASC')
  end

  # GET /authors/1
  # GET /authors/1.json
  def show
    results = Dbpedia.sparql.query("SELECT ?person ?abstract ?name WHERE {
      ?person rdf:type <http://dbpedia.org/ontology/Person>.
      ?person foaf:name ?name.
      ?person dbpedia-owl:abstract ?abstract .
      FILTER (LANG(?abstract)='pl' && ?name=\""+@author.full_name+"\"@en)
      }")
    if results.first != nil
      @bio=results.first[:abstract] 
    end
  end

  # GET /authors/new
  def new
    @author = Author.new
  end

  # GET /authors/1/edit
  def edit
  end

  def search
    index
    render :index
  end
  
  def set_search
    @q = Author.search(params[:q])
  end

  # POST /authors
  # POST /authors.json
  def create
    @author = Author.new(author_params)

    respond_to do |format|
      if @author.save
        format.html { redirect_to @author, notice: 'Author was successfully created.' }
        format.json { render action: 'show', status: :created, location: @author }
      else
        format.html { render action: 'new' }
        format.json { render json: @author.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /authors/1
  # PATCH/PUT /authors/1.json
  def update
    respond_to do |format|
      if @author.update(author_params)
        format.html { redirect_to @author, notice: 'Author was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @author.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /authors/1
  # DELETE /authors/1.json
  def destroy
    @author.destroy
    respond_to do |format|
      format.html { redirect_to authors_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_author
      @author = Author.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def author_params
      params.require(:author).permit(:first_name, :last_name)
    end
end
