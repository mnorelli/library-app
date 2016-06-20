class LibrariesController < ApplicationController

  def index
    @libraries = Library.all
    render :index
  end

  def new
    @library = Library.new
    render :new
  end

  def create
    library_params = params.require(:library).permit(:name, :floor_count, :floor_area)
    library = Library.new(library_params)
    if library.save
      redirect_to "/libraries"
    else
      redirect_to new_library_path
    end
  end



end
