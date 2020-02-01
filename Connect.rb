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

  # Initalize the Browser
  browser = Watir::Browser.new :firefox
  # Navigate to Page
  browser.goto 'http://demo.bendigobank.com.au'
  # Navigate to Demo page
  browser.button(name: 'customer_type').click

  accounts = Array[]
  i=0

  list = browser.ol(class: 'grouped-list__group__items')
  list.lis.each do |li|

    name = li.div(class: '_3jAwGcZ7sr').text
    currency = li.dd(class: 'S3CFfX95_8').span(index: 1).text
    balance = currency
    nature = "credit_card"
    transactions = Array[]
    
    account = Accounts.new(name,currency[0],balance[1..-1],nature,transactions).to_hash

    accounts[i] = account
    hashacc = {"accounts":[accounts[i]]}
    puts ("\n" + hashacc.to_json)
    i+=1
  end
browser.close
