class HueController < Sinatra::Base
  get "/" do
    haml :index, :locals => {:action => "index"}
  end
end