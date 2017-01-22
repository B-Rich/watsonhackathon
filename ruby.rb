
require 'sinatra'
require "sinatra/json"
require 'json'
require "net/http"
require "uri"
APP_ID = "0a8a9487-5c36-4be9-b466-c33e7695718c"
APP_SECRET = "2lb6h5x3t616wa9pjjdswx0bqlwutuiy"
webhook = "aujnz0q74zqu1vz0i9qcelssxo4b5gr2"

annotations_file = "annotations.txt"

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
    f = File.open(annotations_file,'a')
    f.puts(request.body.string+"\n\n\n")
    f.close()
  end
end
