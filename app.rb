require 'sinatra'
require "sinatra/reloader"
require_relative 'lib/database_connection'
require_relative 'lib/album_repository'
require_relative 'lib/artist_repository'

DatabaseConnection.connect

class Application < Sinatra::Base
  configure :development do
    register Sinatra::Reloader
    also_reload 'lib/album_repository'
    also_reload 'lib/artist_repository'
  end

  get '/albums' do
    repo = AlbumRepository.new
    @albums = repo.all

    return erb(:albums)
  end
  
  get '/albums/new' do
    return erb(:new_album)
  end

  get '/albums/:id' do
    repo = AlbumRepository.new
    @artists_repo = ArtistRepository.new
    @album = repo.find(params[:id])
    @artist = @artists_repo.find(@album.artist_id)
    
    return erb(:album_id) 
  end

  post '/albums' do
    if invalid_album_parameters?
      status 400
      return ''
    end
    repo = AlbumRepository.new
    @new_album = Album.new
    @new_album.title = params[:title]
    @new_album.release_year = params[:release_year]
    @new_album.artist_id = params[:artist_id]
    
    repo.create(@new_album)
    
    return erb(:created_album)
  end

  get '/artists' do
    repo = ArtistRepository.new
    @artists = repo.all

    return erb(:artists)
  end

  get '/artists/new' do
    erb(:new_artist)
  end

  get '/artists/:id' do
    repo = ArtistRepository.new
    @artists = repo.all

    @artist = repo.find(params[:id])

    return erb(:artist_id)
  end

  post '/artists' do
    if invalid_artist_parameters?
      status 400
      return ''
    end
    repo = ArtistRepository.new

    @new_artist = Artist.new
    @new_artist.name = params[:name]
    @new_artist.genre = params[:genre]

    repo.create(@new_artist)

    return erb(:created_artist)
  end

  private

  def invalid_album_parameters?
    params[:title] == nil || params[:release_year] == nil || params[:artist_id] == nil
  end

  def invalid_artist_parameters?
    params[:name] == nil || params[:genre] == nil
  end
end