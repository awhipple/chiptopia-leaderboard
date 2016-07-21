# Helper file to convert a YML file to the base64 encoding used in the ENV variable

require 'base64'
require 'yaml'

cards = File.read('cards.yml')
cards_base_64 = Base64.urlsafe_encode64 cards
out = File.open('cards.yml.base64', 'w')
out.write(cards_base_64)
out.close
