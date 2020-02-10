require 'rspec'
require 'nokogiri'
require_relative 'account.rb'
require_relative 'transaction.rb'
require_relative 'bendigobank.rb'

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

  describe "count the transactions" do
    it 'returns true if number of transctions is 15' do
      expect(transactions.count).to eq(15)
    end
  end

  describe "validate the first account" do
    it 'returns true if accounts[0] is valid' do
      expect(accounts.first.to_h).to eq(
        {
          "name"=>"Demo Everyday Account",
          "currency"=>"$",
          "balance"=>"1,860.15",
          "nature"=>"Account",
          "transactions"=>nil
        }
      )
    end
  end

  describe "validate the first transaction" do
    it 'returns true if transactions[0] is valid' do
      expect(transactions.first.to_h).to eq(
        {
          "date"=>"February 7, 2020",
          "description"=>"00001669907602",
          "amount"=>"-34.00",
          "currency"=>"$",
          "account_name"=>"account_name"
        }
      )
    end
 end
end
