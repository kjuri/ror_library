class BooksController < ApplicationController
  before_action :set_book, only: [:show, :edit, :update, :destroy]
  before_action :set_authors, only: [:new, :edit, :update, :create]
  before_action :set_categories, only: [:show, :new, :edit, :update, :create]
  before_action :set_reservations, only: [:index, :show]
  before_action :authenticate_user!, except: [:index, :show]
  # GET /books
  # GET /books.json
  def index
    @q = Book.search(params[:q])
    @books = @q.result(distinct: true).paginate(:page => params[:page]).order('title ASC')
  end

  # GET /books/1
  # GET /books/1.json
  def show
    if @book.author.last_name == nil || @book.author.first_name == nil
      author = '[brak inf. o autorze]. '
    else
      author = @book.author.last_name + ', ' + @book.author.first_name + '. '
    end
    if @book.title == nil
      title = '[brak inf. o tytule]. '
    else
      title = @book.title + '. '
    end
    if @book.place == nil
      place = '[brak inf. o miejscu wyd.]: '
    else
      place = @book.place + ': '
    end
    if @book.publisher == nil
      publisher = '[brak inf. o wydawn.], '
    else
      publisher = @book.publisher + ', '
    end
    if @book.year == nil
      year = '[brak inf. o roku wyd.]. '
    else
      year = @book.year.to_s + '. '
    end
    if @book.isbn == nil
      isbn = '[brak inf. o numerze ISBN].'
    else
      isbn = 'ISBN ' + @book.isbn + '.'
    end
    @iso690 = author + title + place + publisher + year + isbn
  end

  def marc
    if params[:q]
      @q = params[:q]
      error_status = 1
      if /(^100)(\s)*(\d)*(\#)*(\$[a-z])*[\w\-]+,(\s)[\w]+/ =~ @q
        @name = /(^100)(\s)*(\d)*(\#)*(\$[a-z])*[\w\-]+,(\s)[\w]+/.match(@q).to_s
        error_status = 0
      else
        error_status = 1
      end
      if /[\AA-Z]{1}[a-z]+\-?[A-Z]?[\za-z]*/ =~ @name && /[\AA-Z]{1}[a-z]+\-?[A-Z]?[a-z]*\z/ =~ @name
        @last_name = /[\AA-Z]{1}[a-z]+\-?[A-Z]?[\za-z]*/.match(@name).to_s
        @first_name = /[\AA-Z]{1}[a-z]+\-?[A-Z]?[a-z]*\z/.match(@name).to_s
        error_status = 0
      else
        error_status = 1
      end
      if /(^245)(\s)*(\d)*(\#)*(\$[a-z])*(\w|\s)*(\:)*(\$)*(\w)?(\w|\s|\d|\,|\-)*/ =~ @q
        @title = /(^245)(\s)*(\d)*(\#)*(\$[a-z])*(\w|\s)*(\:)*(\$)*(\w)?(\w|\s|\d|\,|\-)*/.match(@q).to_s
        if /[A-Z]{1}[\w|\s|\.|\:]*/ =~ @title
          @title1 = /[A-Z]{1}[\w|\s|\.|\:]*/.match(@title).to_s
          error_status = 0
          if /(\$b)(\w|\s|\,|\d|\-)*/ =~ @title
            @title2 = /(\$b)(\w|\s|\,|\d|\-)*/.match(@title).to_s
            @title = @title1 + @title2[2..-1]
            error_status = 0
          else
            @title = @title1
            error_status = 0
          end
        else
          error_status = 1
        end
      else
        error_status = 1
      end
      if /(^020)(\s)*(\#)*(\$)?(\w)?(\d){10,13}/ =~ @q
        @isbn = /(^020)(\s)*(\#)*(\$)?(\w)?(\d){10,13}/.match(@q).to_s
        if /(\d){10,13}/ =~ @isbn
          @isbn = /(\d){10,13}/.match(@isbn).to_s
          error_status = 0
        else
          error_status = 1
        end
      else
        error_status = 1
      end
      if /(^260)(\s)*(\#)*(\$a)*(\w|\s|\d|\:|\$|\,)*/ =~ @q
        @publishing = /(^260)(\s)*(\#)*(\$a)*(\w|\s|\d|\:|\$|\,)*/.match(@q).to_s
        if /\$a(\w|\s)*/ =~ @publishing
          @place = /\$a(\w|\s)*/.match(@publishing).to_s
          if /([A-Z][a-z]*\s)+/ =~ @place 
            @place = /([A-Z][a-z]*\s)+/.match(@place).to_s
            error_status = 0
          else
            error_status = 1
          end
        else
          error_status = 1
        end
        if /\$b(\w|\s)*/ =~ @publishing
          @publisher = /\$b(\w|\s)*/.match(@publishing).to_s
          if /([A-Z][a-z]*|\s)+/ =~ @publisher
            @publisher = /([A-Z][a-z]*|\s)+/.match(@publisher).to_s
            error_status = 0
          else
            error_status = 1
          end
        else
          error_status = 1
        end
        if /([A-Z][a-z]*|\s)+/ =~ @publishing 
          @year = /(\$cc)(\d){4}/.match(@publishing).to_s
          if /(\d){4}/ =~ @year
            @year = /(\d){4}/.match(@year).to_s
            error_status = 0
          else
            error_status = 1
          end
        else
          error_status = 1
        end
      else
        error_status = 1
      end
      
      if error_status == 1
        respond_to do |format|
          format.html { redirect_to :back, alert: 'Niepoprawny format MARC. Wymagane pola: 020 ISBN, 100 Tytul, 245 Autor, 260 $a Miejsce wydania $b Wydawnicwo $cc Rok wydania.' }
        end
      elsif error_status == 0
          author = Author.find_by(first_name: @first_name, last_name: @last_name)
          if author.nil?
            author = Author.new
            author.first_name = @first_name
            author.last_name = @last_name
            author.save
          end

        @book = Book.new
        @book.title = @title
        @book.author = author
        @book.place = @place
        @book.publisher = @publisher
        @book.year = @year
        @book.isbn = @isbn
        
        book = Book.find_by(title: @book.title, isbn: @book.isbn)

        respond_to do |format|
          if book != nil
            format.html { redirect_to :back, alert: 'Ksiazka o podanym tytule i ISBN juz istnieje w naszej bazie.' }
          elsif @book.save && error_status == 0
            format.html { redirect_to @book, notice: 'Dodano ksiazke!' }
            format.json { render action: 'show', status: :created, location: @book }
          end
        end
      end
    end
end

  # GET /books/new
  def new
    @book = Book.new
  end
  
  def search
    index
    render :index
  end

  # GET /books/1/edit
  def edit
  end

  # POST /books
  # POST /books.json
  def create
    @book = Book.new(book_params)

    respond_to do |format|
      if @book.save
        format.html { redirect_to @book, notice: 'Book was successfully created.' }
        format.json { render action: 'show', status: :created, location: @book }
      else
        format.html { render action: 'new' }
        format.json { render json: @book.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /books/1
  # PATCH/PUT /books/1.json
  def update
    respond_to do |format|
      if @book.update(book_params)
        format.html { redirect_to @book, notice: 'Book was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @book.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /books/1
  # DELETE /books/1.json
  def destroy
    @book.destroy
    respond_to do |format|
      format.html { redirect_to books_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_book
      @book = Book.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def book_params
      params.require(:book).permit(:title, :author_id, {:category_ids => []}, :place, :publisher, :year, :isbn)
    end

 protected
  def set_authors
    @authors = Author.find(:all).map do |author|
      [ author.full_name, author.id]
    end
  end 

  def set_categories
    @categories = Category.find(:all).map do |category|
      [ category.name, category.id]
    end
  end

  def set_reservations
    @reservations = Reservation.find(:all).map do |reservation|
      [ reservation.book_id ]
    end
  end

end

def is_available(book)
  result = Reservation.find_by_book_id(book.id)
  if result == nil
    return true
  else
    return false
  end
end
