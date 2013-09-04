cwd = File.dirname(File.dirname(File.absolute_path(__FILE__)))
$:.unshift(cwd + "/lib")
require 'balanced'

begin
  Balanced::Card
rescue NameError
  raise "wtf"
end

require 'balanced'

Balanced.configure("8bb66df4e80711e290df026ba7cd33d0")

puts "create our marketplace"
begin
  marketplace = Balanced::Marketplace.new.save
rescue Balanced::Conflict => ex
  # balanced automatically maps the body's response
  # for convenience, so for example:
  puts ex.response[:body]
  # you'll notice this hash is mapped to nice attributes
  raise "Not Present" if ex.response[:body]["status"] != ex.status
  # you can find all of the attributes here:
  # https://docs.balancedpayments.com/current/api?language=bash#errors
  marketplace = Balanced::Marketplace.mine
end

# create a new card

card = Balanced::Card.new(
  :card_number => "5105105105105100",
  :expiration_month => "12",
  :expiration_year => "2015",
  :phone_number => "INCORRECT PHONE NUMBER"
)

begin
  card.save
rescue Balanced::BadRequest => ex
  puts ex.extras[:phone_number]
  puts "All the fields that have errors are: #{ex.extras.keys}"
end

# create our marketplace
# {"status"=>"Conflict", "category_code"=>"marketplace-already-created", "additional"=>nil, "status_code"=>409, "extras"=>{}, "category_type"=>"logical", "_uris"=>{}, "request_id"=>"OHM618ef024153811e3853a026ba7cd33d0", "description"=>"Marketplace already created. Your request id is OHM618ef024153811e3853a026ba7cd33d0."}
# "INCORRECT PHONE NUMBER" must have length <= 15
# All the fields that have errors are: ["phone_number"]
