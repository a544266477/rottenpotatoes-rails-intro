class MoviesController < ApplicationController

    def show
      id = params[:id] # retrieve movie ID from URI route
      @movie = Movie.find(id) # look up movie by unique ID
      # will render app/views/movies/show.<extension> by default
    end
  
    def index
      #@movies = Movie.all
      @all_ratings = Movie.all_ratings
      if params[:ratings].nil?
        @ratings_to_show = check
      else
        session[:ratings] = params[:ratings]
        @ratings_to_show = check
      end

      if not params[:sort].nil?
        session[:sort] = params[:sort]
      end

      if session[:sort]
        @title_header = find_title('title')
        @date_header = find_title('release_date')
        @movies = Movie.where(rating: @ratings_to_show).order(session[:sort])
      else
        @movies = Movie.where(rating: @ratings_to_show)
      end
      @ratings_to_show = Hash[@ratings_to_show.map {|e| [e, '1']}]
    end
  
    def new
      # default: render 'new' template
    end
  
    def create
      @movie = Movie.create!(movie_params)
      flash[:notice] = "#{@movie.title} was successfully created."
      redirect_to movies_path
    end
  
    def edit
      @movie = Movie.find params[:id]
    end
  
    def update
      @movie = Movie.find params[:id]
      @movie.update_attributes!(movie_params)
      flash[:notice] = "#{@movie.title} was successfully updated."
      redirect_to movie_path(@movie)
    end
  
    def destroy
      @movie = Movie.find(params[:id])
      @movie.destroy
      flash[:notice] = "Movie '#{@movie.title}' deleted."
      redirect_to movies_path
    end
    

    def ratings
      ratings = Array.new
      movies = Movie.all
      movies.each do |movie|
         ratings.push movie[:rating]
         ratings.uniq!
      end
      return ratings
    end

    private
    # Making "internal" methods private is not required, but is a common practice.
    # This helps make clear which methods respond to requests, and which ones do not.
    def movie_params
      params.require(:movie).permit(:title, :rating, :description, :release_date)
    end

    def check
      if session[:ratings]
        session[:ratings].keys
      else
        @all_ratings
      end
    end
  
    
    def find_title(header)
      session[:sort] == header ? 'hilite' : nil
    end
    helper_method :find_title
  end