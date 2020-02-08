require 'watir'
require 'json'
require 'nokogiri'
require 'date'
require_relative 'account.rb'
require_relative 'transaction.rb'

class Bendigobank
  URL = "http://demo.bendigobank.com.au"

  def self.execute
    connect
    fetch_accounts
    fetch_transactions
    show_output
  end

  def self.connect
    Watir.logger.ignore :deprecations
    @browser = Watir::Browser.new :firefox
    @browser.goto URL
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

     @browser.ol(class: 'grouped-list__group__items').each_with_index do |li,i|
       li.a(class: 'panel--hover').click
       @browser.i(class: 'ico-nav-bar-filter_16px').click
       @browser.a(class: 'panel--bordered__item').click
       @browser.ul(class: 'radio-group').li(index: 8).click
       @browser.text_field(name: 'toDate').set(to_date)
       @browser.text_field(name: 'fromDate').set(from_date)
       @browser.button(class: 'button--primary').click
       @browser.button(class: 'button--primary').click
       until @browser.div(class: '_3Wd5wOSiEN').present?
         if @browser.div(class: 'full-page-message').present?
           break
         end
         @browser.scroll.to :bottom
       end
       html = Nokogiri::HTML.fragment(@browser.div(class: 'activity-container').html)
       account_name = @browser.h2(class: 'yBcmat9coi').text

       parse_transactions(html,account_name)

       @accounts[i]["transactions"] = @transaction
     end
  end

  def self.parse_accounts(html)
    @accounts = []
     html.css('.grouped-list__group__items li').each do |li|
      name = li.css('._3jAwGcZ7sr').text
      balance = li.css('.S3CFfX95_8').text
      currency = balance[19]
      nature = name.split.last
      transactions = nil
      @accounts.push(Accounts.new(name,currency,balance[20..-1],nature,transactions).to_hash)
     end
  end

  def self.parse_transactions(html,account_name)
    @transaction = []
    html.css('.grouped-list--indent').css('.grouped-list__group').each do |li|
      date = li.css('.grouped-list__group__heading').text
      li.css('.grouped-list__group__items li').each do |li|
         description = li.css('.sub-title').text
         amountDebit = li.css('.lQBoxl_Y_x').text
         amountCredit = li.css('._32o6RiLlUL').text
         amountCredit == "" ? amount = "-"+amountDebit[20..-1] : amount = "+"+amountCredit[20..-1]
         currency = amountDebit[19] || amountCredit[19]
         @transaction.push(Transactions.new(date,description,amount,currency,account_name).to_hash)
       end
    end
  end

  def self.show_output
    hash = {"accounts":@accounts}
    puts JSON.pretty_generate(hash)
  end
execute
end
