
require 'sinatra'
require "sinatra/json"
require 'json'
require "net/http"
require "uri"
APP_ID = "7e2cff45-b9cb-4dac-b5a8-76b05b30ba4b"
APP_SECRET = "divltdwzi227thllqi8gr7x0ueb1omi"
webhook = "6lrw4qygp4wvqn7rc47tusudfgqlafah"


require 'net/http'
require 'uri'
require 'pp'

uri = URI.parse("https://api.watsonwork.ibm.com/oauth/token")
reqq = Net::HTTP::Post.new(uri)
reqq.basic_auth(APP_ID, APP_SECRET)
reqq.set_form_data(
  "grant_type" => "client_credentials",
)

req_options = {
  use_ssl: uri.scheme == "https",
}

response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
  http.request(reqq)
end
pp JSON.parse(response.body)["access_token"]
access_token = JSON.parse(response.body)["access_token"]

require 'openssl'
require 'httparty'

key = webhook
digest = OpenSSL::Digest.new('sha256')

spaceId = ""
host = "https://api.watsonwork.ibm.com/v1/spaces/#{spaceId}/messages"
require_relative 'message'
require_relative 'annotation'

body = Message.new
body.text = "hey babe, wyd"
res = HTTParty.post( host, :headers => { "Authorization" => "Bearer #{access_token}", 'Content-Type' => 'application/json'}, :body => body.to_json)



post '/webhook' do
  if JSON.parse(request.body.string)['type'] == "verification"
    headers['X-OUTBOUND-TOKEN'] = "#{OpenSSL::HMAC.hexdigest('sha256', key, json(response: JSON.parse(request.body.string)['challenge']))}"
    json(response: JSON.parse(request.body.string)['challenge'])
  else
    pp request.env
    pp request.body.string
  end
end
