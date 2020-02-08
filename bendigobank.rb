require 'watir'
require 'json'
require 'nokogiri'
require 'date'
require_relative 'account.rb'
require_relative 'transaction.rb'

class Bendigobank

  def self.execute
    connect
    fetch_accounts
    fetch_transactions
  end

  def self.connect
    Watir.logger.ignore :deprecations
    @browser = Watir::Browser.new :firefox
    @browser.goto 'http://demo.bendigobank.com.au'
    @browser.button(name: 'customer_type').click
  end

  def self.fetch_accounts
    html = Nokogiri::HTML.fragment(@browser.ol(class: "grouped-list grouped-list--compact").html)
    parse_accounts(html)
  end

  def self.fetch_transactions
    to_date = Time.new().to_datetime
    from_date = to_date << 2
    if from_date.month < 10
      from_date = from_date.day.to_s + "/" + "0" + from_date.month.to_s + "/" + from_date.year.to_s
    end
    if to_date.month < 10 && to_date.day < 10
      to_date = "0" + to_date.day.to_s + "/" + "0" + to_date.month.to_s + "/" + to_date.year.to_s
      from_date = "0" + from_date.day.to_s + "/" + from_date.month.to_s + "/" + from_date.year.to_s
    elsif to_date.month < 10
      to_date = to_date.day.to_s + "/" + "0" + to_date.month.to_s + "/" + to_date.year.to_s
    elsif date.day < 10
      to_date = "0" + to_date.day.to_s + "/" + to_date.month.to_s + "/" + to_date.year.to_s
      from_date = "0" + from_date.day.to_s + "/" + from_date.month.to_s + "/" + from_date.year.to_s
    end
    accounts = @browser
     accounts.ol(class: "grouped-list grouped-list--compact").li(index: 0).ol(class: 'grouped-list__group__items').each do |li|
       li.a(class: 'g9Ab3g8sIZ').click
       accounts.i(class: 'ico-nav-bar-filter_16px').click
       accounts.a(class: 'panel--bordered__item').click
       accounts.ul(class: 'radio-group').li(index: 8).click
       accounts.text_field(name: 'toDate').set(to_date)
       accounts.text_field(name: 'fromDate').set(from_date)
       accounts.button(class: 'button--primary').click
       accounts.button(class: 'button--primary').click
       while accounts.div(class: '_3Wd5wOSiEN').present? != true
         if accounts.div(class: 'full-page-message').present? == true
           break
         end
         accounts.scroll.to :bottom
       end
       html = Nokogiri::HTML.fragment(accounts.div(class: 'activity-container').html)
       account_name = accounts.h2(class: 'yBcmat9coi').text
       parse_transactions(html,account_name)
     end
  end

  def self.parse_accounts(html)
     html.css('.grouped-list__group__items li').each do |li|
      name = li.css('._3jAwGcZ7sr').text
      balance = li.css('.S3CFfX95_8').text
      currency = balance[19]
      nature = "credit_card"
      transactions = Array[]
      @account = Accounts.new(name,currency,balance[20..-1],nature,transactions).to_hash
     end
  end

  def self.parse_transactions(html,account_name)
    html.css('.grouped-list--indent').css('.grouped-list__group').each do |li|
      date = li.css('.grouped-list__group__heading').text
      li.css('.grouped-list__group__items').css('._2EcJACN7jc').each do |li|
         #get related data for transactions class object
         description = li.css('.sub-title').text
         amountDebit = li.css('.lQBoxl_Y_x').text
         amountCredit = li.css('._32o6RiLlUL').text
         amountCredit == "" ? amount = "-"+amountDebit[20..-1] : amount = "+"+amountCredit[20..-1]
         @transaction = Transactions.new(date,description,amount,"",account_name).to_hash
       end
    end
  end

execute
end
