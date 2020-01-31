require 'watir'
require 'webdrivers'
require 'faker'
require 'json'

class Accounts
  attr_accessor :name, :currency, :balance, :nature, :transactions
  def initialize(name,currency,balance,nature,transactions)
    @name = name
    @currency = currency
    @balance = balance
    @nature = nature
    @transactions = transactions
  end
  def to_hash
    hash = {}
    instance_variables.each { |var| hash[var.to_s.delete('@')] = instance_variable_get(var) }
    hash
  end
end

def get_accounts_data
  # Initalize the Browser
  browser = Watir::Browser.new :firefox
  # Navigate to Page
  browser.goto 'http://demo.bendigobank.com.au'
  # Navigate to Demo page
  browser.button(name: 'customer_type').click
  name = Array[]
  accounts = Array[]

  i=0
  list = browser.ol(class: 'grouped-list__group__items')
  list.lis.each do |li|
    name[i] = li.div(class: '_3jAwGcZ7sr').text
    account = Accounts.new(name[i],"text","text","text","text").to_hash
    accounts[i] = account
    hashacc = {"accounts":[accounts[i]]}
    puts (hashacc.to_json)
    i+=1
end
browser.close

end

get_accounts_data
