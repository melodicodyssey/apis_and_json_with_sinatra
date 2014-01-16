require 'sinatra'
require 'sinatra/reloader'
require 'typhoeus'
require 'json'


get '/' do
  html = %q(
  <html>
  <head>
    <title>Movie Search</title>
    <style>
      body {
        background-color: #ededed
      }
      h1 {
        font-family: Courier
      }
    </style>
  </head>
  <body>
    <center>
    <h1>Find a Movie!</h1>
    <form accept-charset="UTF-8" action="/result" method="post">
    <label for="movie">Search for:</label>
    <input id="movie" name="movie" type="text" />
    <input name="commit" type="submit" value="Search" /> 
    </form>
    <form action="/hi" method="post">
    <input name="say hi" type="submit" value="Say Hi" />
    </form>
    </center>
  </body>
  </html>
  )
end

post '/hi' do
  html_str = "
  <html>
  <head>
    <title>Hi there</title>
  <body>
  <center>
    <h1>Hello there</h1>
    <h3>This is a test page</h3>
  </center>
  </body>
  </html>"
end

post '/result' do
  search_str = params[:movie]

  # Make a request to the omdb api here!
  result = Typhoeus.get("www.omdbapi.com/",:params => {:s => search_str})
  response = JSON.parse(result.body)
  sorted_response = response['Search'].sort_by {|movie| movie['Year']}

  # Modify the html output so that a list of movies is provided.
  html_str = "
  <html>
  <head>
    <title>Movie Search Results</title>
  </head>
  <body style='background-color: #ededed'>
    <center>
    <h1 style='font-family:Courier'>Movie Results</h1>\n
    <ul>"

  sorted_response.each do |movie|
    html_str += "
      <li>
        <a href=/poster/#{movie['imdbID']}>#{movie['Title']} - #{movie['Year']}</a>
      </li>"
  end

  html_str += "
    </ul>
  </center>
  </body>
  </html>"

end
#imdbID
get '/poster/:imdb' do
  # Make another api call here to get the url of the poster.
  search_str = params[:imdb].to_s
  result = Typhoeus.get("www.omdbapi.com/?i=#{search_str}")
  parser = JSON.parse(result.body)
  html_str = "
  <html>
  <head>
    <title>Movie Poster</title>
  </head>
  <body style='background-color: #ededed'>
    <center>
    <h1 style='font-family:Courier'>Movie Poster</h1>\n"
  html_str += "
    <h3>#{parser['Title']}</h3>"
  html_str += "
    <img src=#{parser['Poster']} />"
  html_str += '
    <br /><a href="/">New Search</a>
  /center>
  </body>
  </html>'

end