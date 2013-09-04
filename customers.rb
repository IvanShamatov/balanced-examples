cwd = File.dirname(File.dirname(File.absolute_path(__FILE__)))
$:.unshift(cwd + "/lib")
require 'balanced'


begin
  Balanced::Card
rescue NameError
  raise "wtf"
end

host = ENV.fetch('BALANCED_HOST') { nil }
options = {}
if host
  options[:scheme] = 'http'
  options[:host] = host
  options[:port] = 5000
end

Balanced.configure(nil, options)

puts "create our new api key"
api_key = Balanced::ApiKey.new.save

puts "Our secret is: ", api_key.secret
# Our secret is: 
# f5120732153311e39bac026ba7f8ec28

secret = api_key.secret

puts "configure with our secret #{secret}"
# configure with our secret f5120732153311e39bac026ba7f8ec28

Balanced.configure(secret)

puts "create our marketplace"
begin
  marketplace = Balanced::Marketplace.new.save
rescue Balanced::Conflict => ex
  marketplace = Balanced::Marketplace.mine
end

puts "create a customer"
#
customer = marketplace.create_customer(
          :name           => "Bill",
          :email          => "bill@bill.com",
          :business_name  => "Bill Inc.",
          :ssn_last4      => "1234",
          :address => {
            :line1 => "1234 1st Street",
            :city  => "San Francisco",
            :state => "CA"
          }
  ).save

puts "our customer uri is #{customer.uri}"

puts "create a card and a bank account for our customer"

bank_account = marketplace.create_bank_account(
          :account_number => "1234567980",
          :bank_code => "321174811",
          :name => "Jack Q Merchant"
        )

card = marketplace.create_card(
          :card_number       => "4111111111111111",
          :expiration_month  => "12",
          :expiration_year   => "2015",
        ).save

puts "our bank account uri is #{bank_account.uri}"
puts "our card uri is #{card.uri}"

puts "associate the newly created bank account and card to our customer"

customer.add_card(card)
customer.add_bank_account(bank_account)

puts "check and make sure our customer now has a card and bank account listed"

raise "customer's cards should not be empty" unless customer.cards.any?
raise "customer's bank accounts should not be empty" unless customer.bank_accounts.any?

puts "create a debit on our customer"

customer.debit(
  :amount       => 5000,
  :description  => "new debit"
  )

puts "check to make sure debit is added"

raise "customer should not have 0 debits" unless customer.debits.any?
raise "customer debit should be 5000" unless customer.debits.first.amount == 5000

puts "create a credit on our customer"

customer.credit(
  :amount      => 2500,
  :description => "new credit"
  )

puts "check to make sure credit is added"

raise "customer should not have 0 credits" unless customer.credits.any?
raise "customer should be 2500" unless customer.credits.first.amount == 2500

puts "check to see what is the active card for a customer"

raise "active card is incorrect" unless customer.active_card.id == card.id

puts "check to see what is the active bank_account for a customer"

raise "active bank account is incorrect" unless customer.active_bank_account.id == bank_account.id


# create our new api key
# Our secret is: 
# 25080a3c153811e386f2026ba7d31e6f
# configure with our secret 25080a3c153811e386f2026ba7d31e6f
# create our marketplace
# create a customer
# our customer uri is /v1/customers/AC1bk6fxF5zUtsbXVYzQIAGk
# create a card and a bank account for our customer
# our bank account uri is /v1/marketplaces/TEST-MP19hZVOkzvSjBjWFmMyqaKa/bank_accounts/BA1eGvkzB6SglUim4ec0JqV2
# our card uri is /v1/marketplaces/TEST-MP19hZVOkzvSjBjWFmMyqaKa/cards/CC1gxFaJeBTfGdq5gQWTeNQc
# associate the newly created bank account and card to our customer
# check and make sure our customer now has a card and bank account listed
# create a debit on our customer
# check to make sure debit is added
# create a credit on our customer
# check to make sure credit is added
# check to see what is the active card for a customer
check to see what is the active bank_account for a customer
