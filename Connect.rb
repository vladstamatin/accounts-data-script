require 'watir'
require 'json'
require 'nokogiri'

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

class Transactions < Accounts
  attr_accessor :date, :description, :amount, :currency, :account_name
  def initialize(date,description,amount,currency,account_name)
    @date = date
    @description = description
    @amount = amount
    @currency = currency
    @account_name = account_name
  end
end

class GetAccountsData

    Watir.logger.ignore :deprecations
    #navigate to webpage
    browser = Watir::Browser.new :firefox
    browser.goto 'http://demo.bendigobank.com.au'
    browser.button(name: 'customer_type').click
    #parse accounts related data and iterate over it
    accounts_list = browser.ol(class: 'grouped-list__group__items')
    accounts_list.lis.each do |li|
      #navigate to our account and select last month for transactions
      li.a(class: 'g9Ab3g8sIZ').click #navigate to each account
      browser.i(class: 'ico-nav-bar-filter_16px').click
      browser.a(class: 'panel--bordered__item').click
      browser.ul(class: 'radio-group').li(index: 6).click
      browser.button(class: 'button--primary').click
      browser.a(class: '_2wUV-453gB').wait_until(&:present?)
      #get html through Nokogiri object
      account_object = Nokogiri::HTML.parse(browser.html)
      #get data for account class object
      name = account_object.at_css("h2.yBcmat9coi").text
      currency = "USD"
      balance = account_object.at_css("div._2tzPNu1unf").text
      nature = "credit_card"
      transactions = Array[]
      #parse transactions related data and iterate over it
        account_object.css('.grouped-list--indent').css('.grouped-list__group').each do |li|
         date = li.css('.grouped-list__group__heading').text
         #iterate over each day of transactions
         li.css('.grouped-list__group__items').css('._2EcJACN7jc').each do |li|
            #get related data for transactions class object
            description = li.css('.sub-title').text
            amountDebit = li.css('.lQBoxl_Y_x').text
            amountCredit = li.css('._32o6RiLlUL').text
            amountCredit == "" ? amount = "-"+amountDebit[20..-1] : amount = "+"+amountCredit[20..-1]
            #push object to array of transactions
            transactions.push(Transactions.new(date,description,amount,currency,name).to_hash)
          end
        end
      puts ("\n" )
      #define and create account object, include transactions array
      account = Accounts.new(name,currency,balance,nature,transactions).to_hash
      #create and use hash in order to output the data in right format
      hash = {"accounts":[account]}
      #print the data in JSON format
      puts JSON.pretty_generate(hash)
    end
  #close the browser sesion
  browser.close
  end
