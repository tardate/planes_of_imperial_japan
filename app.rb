require 'sinatra'

set :public_folder, File.dirname(__FILE__)
set :bind, '0.0.0.0'

get '/' do
  redirect '/index.html', 302
end
