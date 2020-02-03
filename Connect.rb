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
      #navigate to select last month for transactions
      li.a(class: 'g9Ab3g8sIZ').click #navigate to each account
      browser.i(class: 'ico-nav-bar-filter_16px').click
      browser.a(class: 'panel--bordered__item').click
      browser.ul(class: 'radio-group').li(index: 6).click
      browser.button(class: 'button--primary').click
      browser.a(class: '_2wUV-453gB').wait_until(&:present?)

      account_object = Nokogiri::HTML.parse(browser.html)
      #get data for account class object
      name = account_object.at_css("div._3jAwGcZ7sr").text
      currency = account_object.at_css("dd._1vKeQVO7xz").text
      #currency = li.dd(class: 'S3CFfX95_8').span(index: 1).text
      balance = currency
      nature = "credit_card"
      transactions = Array[]

      #parse transactions related data and iterate over it
      tstate = true
      if tstate == true
      transactions_list = browser.ol(class: 'grouped-list grouped-list--compact grouped-list--indent')
      end
      if transactions_list.exists? == true
        transactions_list.lis.each do |li|
         #get data time for transactions made in one day
         date = li.h5(class: 'grouped-list__group__heading')
         #iterate over each day of transactions
         transactions_list_box = li.ol(class: 'grouped-list__group__items')
         transactions_list_box.lis.each do |li|
           #get related data for transactions class object
           description = li.div(class: 'h6 overflow-ellipsis sub-title').text
           amountDebit = li.span(class: 'amount debit')
           amountCredit = li.span(class: 'amount credit')
           amountDebit.exists? == true ? amount = "-"+amountDebit.text : amount = "+"+amountCredit.text
           #push object to array of transactions
           transactions.push(Transactions.new(date.text,description,amount,currency[0],name).to_hash)
         end
        end
      else tstate = false
      end
      puts ("\n" )
      #define and create account object, include transactions array
      account = Accounts.new(name,currency[0],balance[1..-1],nature,transactions).to_hash
      #create and use hash in order to output the data in right format
      hash = {"accounts":[account]}
      #print the data in JSON format
      puts JSON.pretty_generate(hash)
    end
  #close the browser sesion
  browser.close
  end
