require 'uri'
require 'json'
require 'net/http'

API_URL = 'https://api.magicthegathering.io/v1/'

def get_names(set_code)
  page = 1
  ret = []
  uri = URI(API_URL + "cards")
  while true
    params = { page: page, pageSize: 100, set: set_code}
    uri.query = URI.encode_www_form(params)
    res = Net::HTTP.get_response(uri)

    if not res.is_a?(Net::HTTPSuccess)
      puts 'http connection fail'
      exit
    end


    hash = JSON.parse(res.body)

    if hash['cards'].length == 0
      puts 'last page'
      break
    end

    hash['cards'].each do |card|

      if not card['foreignNames']
        puts card['name']
        next 
      end

      set_code = card['set']
      number = card['number']
      names = card['foreignNames'].map do |f|
        f['name']
      end 
      ret << [set_code, number, names]
    end

    puts ret.length
    puts ret.last
    page +=1
  end
  ret
end

def get_sets
  ret = []
  page = 1
  while true
    params = { page: page, pageSize: 100}
    uri = URI(API_URL + "sets")
    uri.query = URI.encode_www_form(params)
    res = Net::HTTP.get_response(uri)

    if not res.is_a?(Net::HTTPSuccess)
      puts 'http connection fail'
      exit
    end

    hash = JSON.parse(res.body)

    if hash['sets'].length == 0
      puts 'last page'
      break
    end
    page += 1

    hash['sets'].each do |set|
      code = set['code']
      name = set['name']
      ret << [code, name]
    end
  end
  ret
end
