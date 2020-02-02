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
  def get_accounts_data
    Watir.logger.ignore :deprecations
    # Initalize the Browser
    browser = Watir::Browser.new :firefox
    # Navigate to Page
    browser.goto 'http://demo.bendigobank.com.au'
    # Navigate to Demo page
    browser.button(name: 'customer_type').click

    accounts_list = browser.ol(class: 'grouped-list__group__items')

    accounts_list.lis.each do |li|

      name = li.div(class: '_3jAwGcZ7sr').text
      currency = li.dd(class: 'S3CFfX95_8').span(index: 1).text
      balance = currency
      nature = "credit_card"
      transactions = Array[]

      li.a(class: 'g9Ab3g8sIZ').click
      browser.i(class: 'ico-nav-bar-filter_16px').click
      browser.a(class: 'panel--bordered__item').click
      browser.ul(class: 'radio-group').li(index: 6).click
      browser.button(class: 'button--primary').click
      browser.a(class: '_2wUV-453gB').wait_until(&:present?)

      state = true
      if state == true
      transactions_list = browser.ol(class: 'grouped-list grouped-list--compact grouped-list--indent')
      end

      if transactions_list.exists? == true
        transactions_list.lis.each do |li|
         date = li.h5(class: 'grouped-list__group__heading')

         transactions_list_box = li.ol(class: 'grouped-list__group__items')
         transactions_list_box.lis.each do |li|

           description = li.div(class: 'h6 overflow-ellipsis sub-title').text
           amountDebit = li.span(class: 'amount debit')
           amountCredit = li.span(class: 'amount credit')
           amountDebit.exists? == true ? amount = "-"+amountDebit.text : amount = "+"+amountCredit.text

          transactions.push(Transactions.new(date.text,description,amount,currency[0],name).to_hash)

         end
        end
      else state = false
      end
      puts ("\n\n\n" )
      account = Accounts.new(name,currency[0],balance[1..-1],nature,transactions).to_hash
      hashacc = {"accounts":[account]}

      puts JSON.pretty_generate(hashacc)
    end
  browser.close

  end

get_accounts_data
