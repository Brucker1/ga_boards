module Bc_boards
	class Server < Sinatra::Base

		enable :sessions

		configure :development do
			register Sinatra::Reloader
			$redis = Redis.new
		end

		get('/') do
			if session[:access_token]
				redirect to("/news")
			end

      query_params = URI.encode_www_form({
        :response_type => "code",
        :client_id     => ENV["Linkedin_Oauth_API_Key"],
        :state         => "D8DCWLC327HVM",
        :redirect_uri  => "http://localhost:9292/linkedin/oauth_callback"
      })
      @linkedin_auth_url = "https://www.linkedin.com/uas/oauth2/authorization?" + query_params
		  render :erb, :index, :layout => :default
		end

		get '/linkedin/oauth_callback' do
			# make a request to get an access token
			response = HTTParty.post(
        "https://www.linkedin.com/uas/oauth2/accessToken",
        :body => {
          :grant_type     => "authorization_code",
          :code           => params[:code],
          :redirect_uri   => "http://localhost:9292/linkedin/oauth_callback",
          :client_id      => ENV["Linkedin_Oauth_API_Key"],
          :client_secret  => ENV["Linkedin_Oauth_Secret_Key"]
        },
        :headers => {
          "Accept"        => "application/json"
        }
      )

			# save the access token for whenever we need it!
      session[:access_token] = response["access_token"]

      # use the access token to ask for name and email as json
      response = HTTParty.get(
      	"https://api.linkedin.com/v1/people/~:(first-name,last-name,email-address)?format=json",
        :headers => {
          "Authorization" => "Bearer #{session[:access_token]}"
        }
      )

      session["name"] = response["firstName"] + " " + response["lastName"]
      # binding.pry
      redirect to("/news")
	  end

		get('/new') do
			render :erb, :new
		end

		get('/signup') do
			render :erb, :sign_up
		end

		get("/news") do
			@name = session["name"]
			render :erb, :news, :layout => :default
		end

	end
end
