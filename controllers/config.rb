class HueController < Sinatra::Base
  get "/config" do
    @username = Digest::SHA1.hexdigest(rand(30 ** 30).to_s)

    haml :config, :locals => {:action => self.config[:ip] ? "config-update" : "config-new", :no_action_css => true}
  end

  post "/config" do
    url = URI("http://#{params[:ip]}/api")

    http = Net::HTTP.new(url.host, url.port)
    res = http.request_post(url.request_uri, {:username => params[:username], :devicetype => params[:devicetype]}.to_json)
    res = JSON.parse(res.body)

    res = res.first
    if res["error"] and res["error"]["type"] == 101
      [400, "waiting"]
    elsif res["error"]
      [400, res["error"]["description"]]
    elsif res["success"]
      self.save_config(:ip => params[:ip], :apikey => params[:username])

      [200, "success"]
    end
  end

  put "/config" do
    self.config[:ip] = params[:ip]

    File.open("./config/config.yml", "w+") do |f|
      f.write(self.config.to_yaml)
    end

    [200, "success"]
  end
end