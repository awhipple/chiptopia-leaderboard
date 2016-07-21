require 'sinatra'
require 'yaml'
require 'httparty'
require 'json'
require 'date'
require 'base64'

cards = YAML.load(Base64.decode64(ENV['CARDS']))

def get_standings(token)
  month = Date.today.month - 6
  response = HTTParty.get("https://chiptopia-api.chipotle.com/v2/profile?token=#{token}", headers: {'Referer' => 'http://localhost'})
  standing = JSON.load(response.body)['standings']['bonusPlanStanding'].select do |item|
    item['bpname'] =~ /^Chiptopia Month #{month}$/
  end
  standing[0]['bpcredit'].to_i
end

get '/' do
  erb :index
end

get '/users' do
  content_type :json
  cards.collect { |k, v| k if v.length != 14 }.compact.to_json # only return users with new token, as opposed to old card numbers
end
get '/chip-status/:name' do |name|
  raise "Not a valid name!" unless name =~ /^[\w\s\\0-9:\-]+$/
  content_type :json
  payload = {success: false, user: name, count: nil}
  if cards.key? name
    payload[:count] = get_standings(cards[name])
    payload[:success] = true
  end
  payload.to_json
end
