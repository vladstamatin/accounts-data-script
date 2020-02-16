require 'watir'
require 'json'
require 'nokogiri'
require 'date'
require_relative 'account.rb'
require_relative 'transaction.rb'

class Bendigobank
  URL = "http://demo.bendigobank.com.au"

  def execute
    connect
    fetch_accounts
    fetch_transactions
    show_output
  end

  def connect
    Watir.logger.ignore :deprecations
    @browser = Watir::Browser.new :firefox
    @browser.goto URL
    @browser.button(name: 'customer_type').click
  end

  def fetch_accounts
    html = Nokogiri::HTML.fragment(@browser.ol(class: "grouped-list grouped-list--compact").html)
    parse_accounts(html)
  end

  def fetch_transactions
    to_date = Time.new().to_datetime
    from_date = to_date << 2

    to_date = format_date(to_date)
    from_date = format_date(from_date)

    @browser.ol(class: 'grouped-list__group__items').each_with_index do |li,i|
      li.a(class: 'panel--hover').click
      @browser.i(class: 'ico-nav-bar-filter_16px').click
      @browser.a(class: 'panel--bordered__item').click
      @browser.ul(class: 'radio-group').li(index: 8).click
      @browser.text_field(name: 'toDate').set(to_date)
      @browser.text_field(name: 'fromDate').set(from_date)
      @browser.button(class: 'button--primary').click
      @browser.button(class: 'button--primary').click
      until @browser.p(text: "No more activity").present?
        if @browser.div(class: 'full-page-message').present?
          break
        end
        @browser.scroll.to :bottom
      end

    html = Nokogiri::HTML.fragment(@browser.div(class: 'activity-container').html)
      account_name = @browser.h2(class: 'yBcmat9coi').text

      parse_transactions(html,account_name)
      #copy related transactions into each account
      @accounts[i]["transactions"] = @transaction
     end
  end

  def parse_accounts(html)
    @accounts = []

     html.css('.grouped-list__group__items li').each do |li|
      name = li.css('._3jAwGcZ7sr').text
      balance = li.css('.S3CFfX95_8').text
      currency = balance[19]
      balance = balance[20..-1].delete ','
      nature = name.split.last
      transactions = []

      @accounts.push(Accounts.new(name,currency,balance.to_f,nature,transactions).to_hash)
     end
     return @accounts
  end

  def parse_transactions(html,account_name)
    @transaction = []

    html.css('.grouped-list--indent').css('.grouped-list__group').each do |li|
      date = li.css('.grouped-list__group__heading').text
      li.css('.grouped-list__group__items li').each do |li|
         description = li.css('.sub-title').text
         amountDebit = li.css('.lQBoxl_Y_x').text
         amountCredit = li.css('._32o6RiLlUL').text
         amountCredit == "" ? amount = "-" + amountDebit[20..-1] : amount = "+" + amountCredit[20..-1]
         amount = amount.delete ','
         currency = amountDebit[19] || amountCredit[19]

         @transaction.push(Transactions.new(date,description,amount.to_f,currency,account_name).to_hash)
       end
    end
    return @transaction
  end

  def format_date(date)
    case
    when date.month < 10 && date.day < 10
      date = "0" + date.day.to_s + "/" + "0" + date.month.to_s + "/" + date.year.to_s
    when date.month < 10
      date = date.day.to_s + "/" + "0" + date.month.to_s + "/" + date.year.to_s
    when date.day < 10
      date = "0" + date.day.to_s + "/" + date.month.to_s + "/" + date.year.to_s
    else
      date = date.day.to_s + "/" + date.month.to_s + "/" + date.year.to_s
    end
  end

  def show_output
    hash = {"accounts":@accounts}
    puts JSON.pretty_generate(hash)
  end

end

bendigobank = Bendigobank.new
bendigobank.execute
