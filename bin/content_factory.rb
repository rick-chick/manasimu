require_relative "./db_util.rb"

setCode = ARGV[0]
number = ARGV[1]
condition = [setCode, number]
where = 'setCode = ? and number = ?'

aggre = all_card_details(where, condition)
puts aggre.find(setCode, number).to_factory
