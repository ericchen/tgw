$LOAD_PATH.unshift "#{File.dirname(__FILE__)}/lib", *Dir["#{File.dirname(__FILE__)}/vendor/**/lib"].to_a
require 'rubygems'
require 'sinatra'
require 'yaml'
# gem('twitter4r', '>=0.2.2')
require 'twitter'
#require 'tweetstream'
require 'pretty_date'
require 'httpclient'
require 'mechanize'
# require 'ruby-debug'

before do
  headers "Content-Type" => "text/html; charset=utf-8"
  config = YAML.load_file(File.join(File.dirname(__FILE__), 'config', 'user.yml'))
  Twitter.configure do |cfg|
    cfg.consumer_key = config['ckey']
    cfg.consumer_secret = config['csecret']
    cfg.oauth_token = config['token']
    cfg.oauth_token_secret = config['asecret']
  end
     # @twitter = Twitter::Client.new(config) 
     # oauth = Twitter::OAuth.new(config['ckey'], config['csecret'])
     # oauth.authorize_from_access(config['token'], config['asecret'])  
     # @client = Twitter::Base.new(oauth)
  #    @tstream = TweetStream::Client.new(config['login'], config['password'])
end
 
get '/' do
  #get messages
  @timelines = Twitter.home_timeline(:count => 60)
  erb :tweets
end

get '/goto' do
  httpc = HTTPClient.new
  resp = httpc.get(params[:url])
  real_url = resp.header['Location'].first
  puts real_url.inspect
  puts real_url.class
  redirect real_url || params[:url]
end

get '/user/:u' do
  @timelines = Twitter.user_timeline(params[:u]||'sungyun', :count=>params[:cnt]||100)
  erb :htweets
end

get '/me' do
  @timelines = Twitter.user_timeline('sungyun')
  erb :htweets
end

get '/tweets' do
  @timelines = Twitter.timeline_for(:me)  
  erb :tweets
end

get '/retweet/:id' do
  Twitter.retweet(params[:id])
  redirect '/'
end

get '/search' do
  search = Twitter::Search.new
  @tweets = search.from(params[:user]||"railsconf").per_page(60).fetch
  erb :search
end

get '/daily' do
  @timelines = Twitter::Trends.daily
  erb :tweets
end

get '/weekly' do
  @timelines = Twitter::Trends.weekly
  erb :tweets
end

get '/public' do
  #get messages
  @timelines = @client.public_timeline(:count => 60)
  erb :tweets
end

get '/timelines' do
  two_days_ago = Time.now - 60*60*24*2
  @timelines = @twitter.timeline_for(:friends, :since => two_days_ago)
  erb :tweets
end

get '/messages' do
  @status = []
  @tstream.track('sinatra ruby', 'ruby') do |status|
    	@status << status
  end
  erb :messages
end

get '/home_timeline' do
  @timelines = @client.home_timeline
  erb :tweets
end

get '/test' do
  @status = []
  @tstream.follow(14252, 53235) do |status|
    	@status << status
  end
  erb :messages
end

get '/hello' do
  @page = params[:page].to_i + 1
  erb :hello
end

get '/hello/:page' do
  @page = params[:page].to_i + 1
  erb :hello
end

get '/proxy' do
  if params[:url].to_s.length > 1
    charset = 'utf-8'
    decode_url = Base64.decode64(params[:url].reverse)
    begin
     orig_uri = URI.parse(decode_url)
    rescue URI::InvalidURIError
      @html = "URL not available anymore"
    end
    puts decode_url
    encode_url = URI.encode(decode_url)
    a = Mechanize.new { |agent|
      agent.user_agent_alias = 'Mac Safari'
    }
    begin
      a.get(encode_url) do |page|
        origin_html = page.body
        
        origin_html.gsub!(/href=["']([^'"]+)/).each do |link|
          
          unless link.index(/\.(com|net|cn|org|us|edu|me|hk|cc|jp)/)
            # debugger
            link.gsub!(/href=["']\//, 'href="http://'+orig_uri.host+'/')
          else
            link
          end
          
          # link = Base64.encode64(link).gsub(/\n/,'').reverse
        end
        @html = page.body
        charset = page.encoding
      end

      content_type 'text/html', :charset => charset
    rescue SocketError
      @html = "host not available"
    rescue ArgumentError
      @html = 'absolute URL needed'
    rescue Mechanize::ResponseCodeError, Net::HTTP::Persistent::Error
      @html = "URL not available anymore"
    end
    
    erb :proxy_url, :layout => false
  else
    erb :proxy, :layout => false  
  end
  
end

post '/crypt/url' do
  if params[:url].to_s.length > 1
    params[:url] = 'http://'+params[:url] unless params[:url].index(/^http/)
    encode_url = Base64.encode64(params[:url]).gsub(/\n/,'').reverse
    puts encode_url
    redirect '/proxy?url=' + encode_url
  else
    "Please enter url"
  end
  
end


post '/proxy' do
  if params[:url].to_s.length > 1
    params[:url] = 'http://'+params[:url] unless params[:url].index(/^http/)
    charset = 'utf-8'
    encode_url = URI.encode(params[:url])
    a = Mechanize.new { |agent|
      agent.user_agent_alias = 'Mac Safari'
    }
    begin
      a.get(encode_url) do |page|
        @html = page.body
        charset = page.encoding
      end

      content_type 'text/html', :charset => charset
    rescue Mechanize::ResponseCodeError
      @html = "URL not available anymore"
    end
    
    erb :proxy_url, :layout => false
  else
    erb :proxy, :layout => false  
  end
end



