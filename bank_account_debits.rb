"""
Learn how to authenticate a bank account so you can debit with it.
"""
cwd = File.dirname(File.dirname(File.absolute_path(__FILE__)))
$:.unshift(cwd + "/lib")
require 'balanced'

host = ENV.fetch('BALANCED_HOST') { nil }
options = {}
if host
  options[:scheme] = 'http'
  options[:host] = host
  options[:port] = 5000
end

Balanced.configure(nil, options)

# create a new marketplace
api_key = Balanced::ApiKey.new.save
Balanced.configure(api_key.secret)
marketplace = Balanced::Marketplace.new.save

# create a bank account
bank_account = marketplace.create_bank_account(
    :account_number => "1234567890",
    :bank_code => "12",
    :name => "Jack Q Merchant"
)
account = marketplace.create_account()
account.add_bank_account(bank_account.uri)

puts "you can't debit until you authenticate"
begin
  account.debit(:amount => 100)
rescue Balanced::Error => ex
  puts "Debit failed, %s" % ex.message
end

# authenticate
verification = bank_account.verify

begin
  verification.confirm(1,2)
rescue Balanced::BankAccountVerificationFailure => ex
  puts 'Authentication error , %s' % ex.message
  puts "PROTIP: for TEST bank accounts the valid amount is always 1 and 1"
end
verification = bank_account.verifications.find(:first).first

raise "unpossible" if verification.confirm(1, 1).state != 'verified'
debit = account.debit(:amount => 100)
puts "debited the bank account %s for %d cents" % [
  debit.source.uri,
  debit.amount
]
puts "and there you have it"


# you can't debit until you authenticate
# Debit failed, Balanced::Conflict(409)::Conflict:: POST https://api.balancedpayments.com/v1/marketplaces/TEST-MP5JMJBfZQuWK6Ce6suTud70/accounts/AC5Oom5g2YTWIvksgqPyw7SS/debits: no-funding-source: Account AC5Oom5g2YTWIvksgqPyw7SS has no funding source. Your request id is OHMc0a3b07c153811e3a9ca026ba7c1aba6. 
# Authentication error , Balanced::BankAccountVerificationFailure(409)::Conflict:: PUT https://api.balancedpayments.com/v1/bank_accounts/BA5N0XJZjOm2LgaDk4G7nPRe/verifications/BZ5ThJxwmWnidKBW1VMiKasf: bank-account-authentication-failed: Authentication amounts do not match. Your request id is OHMc323d336153811e3b619026ba7cd33d0. 
# PROTIP: for TEST bank accounts the valid amount is always 1 and 1
# debited the bank account /v1/marketplaces/TEST-MP5JMJBfZQuWK6Ce6suTud70/accounts/AC5Oom5g2YTWIvksgqPyw7SS/bank_accounts/BA5N0XJZjOm2LgaDk4G7nPRe for 100 cents
# and there you have it
