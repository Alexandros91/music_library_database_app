require "spec_helper"
require "rack/test"
require_relative '../../app'

def reset_artists_table
  ar_seed_sql = File.read('spec/seeds/artists_seeds.sql')
  al_seed_sql = File.read('spec/seeds/albums_seeds.sql')
  connection = PG.connect({ host: '127.0.0.1', dbname: 'music_library_app_test' })
  connection.exec(ar_seed_sql)
  connection.exec(al_seed_sql)
end

describe Application do
  # This is so we can use rack-test helper methods.
  before(:each) do 
    reset_artists_table
  end

  include Rack::Test::Methods

  # We need to declare the `app` value by instantiating the Application
  # class so our tests work.
  let(:app) { Application.new }

  context "GET /albums" do
    it 'returns all albums' do
      response = get('/albums')

      expect(response.status).to eq(200)
      expect(response.body).to include '<h1>Albums</h1>'

      expect(response.body).to include "<a href=\"/albums/1\">
          Title: Doolittle
          Released: 1989
        </a><br>"
      expect(response.body).to include "<a href=\"/albums/3\">
          Title: Waterloo
          Released: 1974
        </a><br>"
      expect(response.body).to include "<a href=\"/albums/8\">
          Title: I Put a Spell on You
          Released: 1965
        </a><br>"
    end
  end

  context "GET /albums/new" do
    it 'returns a form page to add a new album' do
      response = get('albums/new')

      expect(response.status).to eq 200
      expect(response.body).to include '<form method="POST" action="/albums">'

      expect(response.body).to include '<label>Album name: </label>'
      expect(response.body).to include '<input type="text" name="title"/>'
      
      expect(response.body).to include '<label>Released: </label>'
      expect(response.body).to include '<input type="text" name="release_year"/>'
      
      expect(response.body).to include '<label>Artist id: </label>'
      expect(response.body).to include '<input type="text" name="artist_id"/>'

      expect(response.body).to include '<input type="submit"/>'
    end
  end

  context "GET albums/:id" do
    context 'when id is 1' do
      it 'returns the HTML content for the album with id 1' do
        response = get('/albums/1')

        expect(response.body).to include '<h1>Doolittle</h1>'
        expect(response.body).to include 'Release year: 1989'
        expect(response.body).to include 'Artist: Pixies'
      end
    end

    context 'when id is 2' do
      it 'returns the HTML content for the album with id 1' do
        response = get('/albums/2')

        expect(response.status).to eq 200
        expect(response.body).to include '<h1>Surfer Rosa</h1>'
        expect(response.body).to include 'Release year: 1988'
        expect(response.body).to include 'Artist: Pixies'
      end
    end
  end
  
  context "POST /albums" do
    context 'when passing some invalid parameters' do
      it 'the status code is 400' do
        response = post('/albums', name: 'Voyage', year: 2022, artist: 2)

        expect(response.status).to eq 400
        expect(response.body).to eq ''
      end
    end
      
    context 'when passing some valid parameters' do
      it 'creates a new album and return a confirmation message' do
        response = post('/albums', title: 'Voyage', release_year: 2022, artist_id: 2)
        
        expect(response.status).to eq(200)
        expect(response.body).to include '<h1>Album Voyage added by the artist with id 2 that was released in 2022</h1>'

        response = get('/albums')
        expect(response.body).to include 'Voyage'
      end
    end
  end

  context "GET /artists" do
    it 'returns all artists' do
      response = get('/artists')
      

      expect(response.status).to eq(200)
      expect(response.body).to include '<h1>Artists</h1>'

      expect(response.body).to include "<a href=\"/artists/1\">
          Name: Pixies
          Genre: Rock
        </a><br>"

      expect(response.body).to include "<a href=\"/artists/2\">
          Name: ABBA
          Genre: Pop
        </a><br>"

      expect(response.body).to include "<a href=\"/artists/4\">
          Name: Nina Simone
          Genre: Pop
        </a><br>"
    end
  end

  context 'GET /artists/new' do
    it 'returns an html form page in order to create a new artist' do
      response = get('/artists/new')

      expect(response.status).to eq 200
      expect(response.body).to include '<form method="POST" action="/artists"/>'

      expect(response.body).to include '<label>Artist name: </label>'
      expect(response.body).to include '<input type="text" name="name"/>'

      expect(response.body).to include '<label>Genre: </label>'
      expect(response.body).to include '<input type="text" name="genre"/>'

      expect(response.body).to include '<input type="submit"/>'
    end
  end

  context "GET /artists/:id" do
    it 'returns an html page with the artist with id 1' do
      response = get('artists/1')

      expect(response.status).to eq(200)
      expect(response.body).to include '<h1>Pixies</h1>'
      expect(response.body).to include 'Genre: Rock'
    end

    it 'returns an html page with the artist with id 3' do
      response = get('artists/3')

      expect(response.status).to eq(200)
      expect(response.body).to include '<h1>Taylor Swift</h1>'
      expect(response.body).to include 'Genre: Pop'
    end
  end

  context "POST /artists" do
    context 'when passing some invalid parameters' do
      it 'the status is 400' do
        response = post('/artists', artist: 'Invalid artist', type: 'Invalid type')

        expect(response.status).to eq 400
        expect(response.body).to eq ''
      end
    end

    context 'when passing some valid parameters' do
      it 'creates a new artist and returns a confirmation message' do
        response = post('/artists', name: 'Wild nothing', genre: 'Indie')
        
        expect(response.status).to eq(200)
        expect(response.body).to include '<h1>A new artist called Wild nothing of the genre Indie was added!</h1>'
        
        response = get('/artists')
        expect(response.body).to include ('Wild nothing')
      end
    end
  end
end
