require 'sinatra'
require 'sinatra/activerecord'
require 'haml'
require 'xmlsimple'
require 'rest_client'

set :database, 'sqlite3:///shortened_urls.db'
set :address, 'localhost:4567'
#set :address, 'exthost.etsii.ull.es:4567'

class ShortenedUrl < ActiveRecord::Base
  # Validates whether the value of the specified attributes are unique across the system.
  validates_uniqueness_of :url
  # Validates that the specified attributes are not blank
  validates_presence_of :url
  #validates_format_of :url, :with => /.*/
  validates_format_of :url, 
       :with => %r{^(https?|ftp)://.+}i, 
       :allow_blank => true, 
       :message => "The URL must start with http://, https://, or ftp:// ."
end

class Countries < ActiveRecord::Base
  # Validates whether the value of the specified attributes are unique across the system.
  validates_uniqueness_of :url, :scope => :country
end

get '/' do
  haml :index
end


post '/' do
  if !params[:custom]
    @short_url = ShortenedUrl.find_or_create_by_url params[:url]
  else
    @short_url = ShortenedUrl.find_or_create_by_url_and_custom(params[:url],params[:custom])
  end
 
   if @short_url.valid?
    haml :success, :locals => { :address => settings.address }
  else
    haml :index
  end
end

get '/paises' do
  @all_countries = Countries.find :all
  haml :countries

end


get '/show' do
  @all_urls = ShortenedUrl.find(:all)
  haml :show
end


get '/search' do
  haml :search
end


post '/search_url' do
    begin
        @url = ShortenedUrl.find_by_url params[:url]
    rescue
        @url = nil
    end
    haml :results
end


post '/search_id' do
    begin 
        @url = ShortenedUrl.find_by_id params[:url].to_i(36)
    rescue
        @url = nil
    end
    haml :results
end


get '/:shortened' do
  
  short_url ||= ShortenedUrl.find_by_id(params[:shortened].to_i(36))
  short_url ||= ShortenedUrl.find_by_custom(params[:shortened].to_i(36))

  xml = RestClient.get "http://api.hostip.info/get_xml.php?ip=#{request.ip}"
  country = XmlSimple.xml_in(xml.to_s, { 'ForceArray' => false })['featureMember']['Hostip']['countryAbbrev']
  
  @URL = Countries.find_or_create_by_url_and_country(short_url.url, country)
  @URL.count = @URL.count + 1
  @URL.save
 
  redirect short_url.url

end


