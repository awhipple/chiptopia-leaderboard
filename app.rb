require 'sinatra'
require 'yaml'
require 'httparty'
require 'json'
require 'date'
require 'base64'

cards = YAML.load(Base64.decode64(ENV['CARDS']))

def get_standings(card_number)
  month = Date.today.month - 6
  response = HTTParty.get("https://chiptopia-api.chipotle.com/?%24method=get&%24route=%2Fmembers%2F#{card_number}%2Fstandings", headers: {'Referer' => 'https://localhost'})
  standing = JSON.load(response.body)['data']['bonusPlanStanding'].select do |item|
    item['bpname'] =~ /^Chiptopia Month #{month}$/
  end
  standing[0]['bpcredit'].to_i
end

get '/' do
  erb :index
end

get '/users' do
  content_type :json
  cards.collect { |k, v| k }.to_json
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
