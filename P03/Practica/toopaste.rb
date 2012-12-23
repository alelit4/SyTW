require 'sinatra'
require 'syntaxi'
require 'erb'


class String
  
  def formatted_body (lang)
    source = %Q{
                [code lang='#{lang}']
                  #{self}
                [/code]
              }
    html = Syntaxi.new(source).process
    %Q{
      <div class="syntax syntax_ruby">
        #{html}
      </div>
    }
  end
end
                
get '/' do
  erb :new
end

post '/' do
  @lang = params[:lang]
  @title = @lang
  @show = params[:input].formatted_body(@lang)
  erb :show
end

