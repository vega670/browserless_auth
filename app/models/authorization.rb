require 'cgi'
require 'uri'

class Authorization < ActiveRecord::Base
  attr_accessible :state, :token, :error
  
  validates :state, :presence => true
  
  def self.get_token_from_code code
    redirect_uri = $config['site_url'] + "/authorizations"
    url = "https://graph.facebook.com/oauth/access_token?" +
      "client_id=#{$config['facebook']['client_id']}" +
      "&redirect_uri=#{redirect_uri}" +
      "&client_secret=#{$config['facebook']['client_secret']}" +
      "&code=#{code}"
    response = Curl::Easy.http_get(url)
    body = response.body_str
    
    begin
      uri = URI.parse("http://site.fake?" + body)
      token_hash = CGI.parse uri.query
      token = token_hash['access_token'].first
    rescue URI::InvalidURIError => e
      begin
        error = JSON.parse response.body_str
      rescue JSON::ParserError => e
        raise "Invalid JSON from Facebook: #{body}"
      end
      raise "Error from Facebook: #{error['error']['message']}"
    end
    token
  end
  
  def graph
    @graph || get_graph_data
  end
  
  def get_graph_data
    url = "https://graph.facebook.com/me?access_token=#{self.token}"
    response = Curl::Easy.http_get(url)
    body = response.body_str
    begin
      graph = JSON.parse body
      
      self.name = graph['name']
      self.external_id = graph['id']
      self.save!
    rescue JSON::ParserError => e
      logger.error "Error when parsing data for token #{self.token}: #{body}"
    end
    graph
  end
end

