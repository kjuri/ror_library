class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  before_filter :set_global_search_variable

  def set_global_search_variable
    @a = Author.search(params[:a])
    @b = Book. search(params[:b])
  end
end
