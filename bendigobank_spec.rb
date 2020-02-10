require 'rspec'
require 'nokogiri'
require_relative 'bendigobank.rb'
require_relative 'account.rb'
require_relative 'transaction.rb'

describe Bendigobank do

  html_account = Nokogiri::HTML(File.read('/home/vlad/Documents/test_task/accounts.html'))
  html_transaction = Nokogiri::HTML(File.read('/home/vlad/Documents/test_task/transactions.html'))

  accounts = Bendigobank.parse_accounts(html_account)
  transactions = Bendigobank.parse_transactions(html_transaction,"account_name")

  describe "count the accounts" do
    it 'returns true if number of accounts is 5' do
      expect(accounts.count).to eq(5)
    end
  end

end
