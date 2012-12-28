# coding: utf-8
require 'sinatra'
set server: 'thin', users: {}

get '/' do
  halt erb(:login) unless params[:user]
  erb :chat, locals: { user: params[:user].gsub(/\W/, '') }
end

get '/stream/:user', provides: 'text/event-stream' do
  stream :keep_open do |out|
    settings.users[params[:user]] = out
    out.callback { puts 'closed'; settings.users.delete out }
  end
end

post '/' do
  nick_name = /\/(.+):.*/
  user = nick_name.match(params[:msg])
  if user.nil?
  mensaje = "<span class=\"nick\">#{params[:user]}:</span> <span class=\"mensaje\">#{params[:msg]}</span>\n"
    settings.users.each_pair { |user, out| out << "data: #{mensaje}\n" }
  else
    settings.users[user[1]] << "data: <b> Mensaje privado de #{params[:user]}  :</b> #{params[:msg].gsub(/\/(.+):/, '')}\n\n"
    settings.users[params[:user]] << "data: <b> Mensaje privado para #{user[1]} :</b> #{params[:msg].gsub(/\/(.+):/, '')}\n\n"
  end
  204
end

__END__

@@ layout
<html>
  <head> 
    <title>Super Simple Chat with Sinatra</title> 
    <meta charset="utf-8" />
    <script src="http://ajax.googleapis.com/ajax/libs/jquery/1/jquery.min.js"></script> 
    <link href="/css/bootstrap.css" rel="stylesheet">
  </head>  
  <body>
    <div class="row-fluid">
      <div class="span4 offset3">
        <h1> Super Simple Chat </h1>
      </div>
    </div>
    <%= yield %>
  </body>
</html>

@@ login
<div class="row-fluid">
  <div class="span4 offset3">
    <h1> Bienvenido !! </h1>
  </div>
</div>
<div class="row-fluid">
  <div class="span4 offset3">
    <form action='/'>
      <label for='user'>User Name:</label>
      <input name='user' value='' />
      <input type='submit' value="GO!" />
    </form>
  </div>
</div>

@@ chat

<div class="row-fluid">
  <div class="span4 offset3">
    <div align= "center">
      <h2>Hola <%= user %>! </h2>
    </div>
  </div>
</div> 

<div class="row-fluid">
  <div class="span4 offset2">
      <pre id='chat'></pre>
  </div>
  <div class="span4 offset">
      <h1>Usuarios</h1>
      
  </div>

</div> 
    
<script>
  // reading
  var es = new EventSource("/stream/" + "<%= user %>");
  es.onmessage = function(e) { $('#chat').append(e.data + "\n") };

  // writing
  $("form").live("submit", function(e) {
    $.post('/', {user: "<%= user %>", msg: $('#msg').val()});
    $('#msg').val(''); $('#msg').focus();
    e.preventDefault();
  });
</script>

<div class="row-fluid">
  <div class="span4 offset2">
    <form>
      <input id='msg' placeholder='type message here...' />
    </form>
  </div>
</div>     