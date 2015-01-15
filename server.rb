module Bc_boards 
	class Server < Sinatra::Base 

		configure :development do 
			register Sinatra::Reloader
			$redis = Redis.new 
		end 

		get('/') do 
	      query_params = URI.encode_www_form({
	        :response_type => "code",
	        :client_id     => ENV["Linkedin_Oauth_API_Key"],
	        :state         => "D8DCWLC327HVM",
	        :redirect_uri  => "http://localhost:9292/linkedin/oauth_callback"
	      })
	      @linkedin_auth_url = "https://www.linkedin.com/uas/oauth2/authorization?" + query_params
		  render :erb, :index, :layout => :default
		end

		get('/new') do 
			render :erb, :new
		end	

		get('/signup') do
			render :erb, :sign_up
		end 

	end
end
