require 'watir'
require 'json'
require 'nokogiri'
require 'date'
require_relative 'account'
require_relative 'transaction'

class Bendigobank

  def self.execute
    connect
    fetch_accounts(connect)
    fetch_transactions(connect)
  end

  def self.connect
    Watir.logger.ignore :deprecations
    browser = Watir::Browser.new :firefox
    browser.goto 'http://demo.bendigobank.com.au'
    browser.button(name: 'customer_type').click
    return browser
  end

  def self.fetch_accounts(browser)
    html = Nokogiri::HTML.fragment(browser.div(class: "_23LTBXgogQ").html)
    parse_accounts(html)
  end

  def self.fetch_transactions(account)
    date = Time.new().to_datetime
    datepast = date << 2
    if datepast.month < 10
      datepast = datepast.day.to_s + "/" + "0" + datepast.month.to_s + "/" + datepast.year.to_s
    end
    if date.month < 10 && date.day < 10
      date = "0" + date.day.to_s + "/" + "0" + date.month.to_s + "/" + date.year.to_s
      datepast = "0" + datepast.day.to_s + "/" + datepast.month.to_s + "/" + datepast.year.to_s
    elsif date.month < 10
      date = date.day.to_s + "/" + "0" + date.month.to_s + "/" + date.year.to_s
    elsif date.day < 10
      date = "0" + date.day.to_s + "/" + date.month.to_s + "/" + date.year.to_s
      datepast = "0" + datepast.day.to_s + "/" + datepast.month.to_s + "/" + datepast.year.to_s
    end
     account.ol(class: "grouped-list__group__items").each do |li|
       li.a(class: 'g9Ab3g8sIZ').click
       account.i(class: 'ico-nav-bar-filter_16px').click
       account.a(class: 'panel--bordered__item').click
       account.ul(class: 'radio-group').li(index: 8).click
       account.text_field(name: 'toDate').set(date)
       account.text_field(name: 'fromDate').set(datepast)
       account.button(class: 'button--primary').click
       account.button(class: 'button--primary').click
       html = Nokogiri::HTML.fragment(account.div(class: "activity-container").html)
       transaction = Array[]
       parse_transactions(html,transaction)
       #print transaction
     end
  end

  def self.parse_accounts(html)
     html.css("ol.grouped-list__group__items li").each do |li|
      name = li.css('._3jAwGcZ7sr').text
      currency = "USD"
      balance = li.css('.S3CFfX95_8').text
      nature = "credit_card"
      transactions = Array[]
      account = Accounts.new(name,currency,balance[20..-1],nature,transactions).to_hash
      #print account
      hash = {"accounts":[account]}
      puts JSON.pretty_generate(hash)
     end
  end

  def self.parse_transactions(html,transaction)
    html.css('.grouped-list--indent').css('.grouped-list__group').each do |li|
      date = li.css('.grouped-list__group__heading').text
      li.css('.grouped-list__group__items').css('._2EcJACN7jc').each do |li|
         #get related data for transactions class object
         description = li.css('.sub-title').text
         amountDebit = li.css('.lQBoxl_Y_x').text
         amountCredit = li.css('._32o6RiLlUL').text
         amountCredit == "" ? amount = "-"+amountDebit[20..-1] : amount = "+"+amountCredit[20..-1]
         transaction.push(Transactions.new(date,description,amount,"","").to_hash)
       end
    end

  end

execute
end
