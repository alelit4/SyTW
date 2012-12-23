require 'rubygems'
require 'sinatra'
require 'haml'

# ÄLexandra


configure do
  enable :sessions
end

before do
	content_type :html 
	@defeat = { rock: :scissors, paper: :rock, scissors: :paper}
	@throws = @defeat.keys
	

end

get '/' do
  
	if session[:user].nil?
		session[:user] = session[:pc] = 0
	end
	haml :form
	
end

post '/' do
  
  redirect "/throw/#{params[:opt]}"
 
end



get '/throw/:type' do
   # the params hash stores querystring and form data
   @player_throw = params[:type].to_sym
   
   halt(403, "You must throw one of the following: '#{@throws.join(', ')}'") unless @throws.include? @player_throw

   @computer_throw = @throws.sample

   if @player_throw == @computer_throw 
      @answer = "There is a tie"
   elsif @player_throw == @defeat[@computer_throw]
      @answer = "Computer wins! #{@computer_throw} defeats #{@player_throw}"
		session[:pc] += 1
	else
      @answer = "Well done! #{@player_throw} beats #{@computer_throw}"
		session[:user] += 1
   end

   haml :answer

end

post '/throw/:type' do
   redirect "/"
end

post '/logout' do
	session.clear
   redirect "/"
end

__END__


