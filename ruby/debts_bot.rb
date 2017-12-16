#!/usr/bin/env ruby

require 'bundler/inline'
require 'irb'

gemfile(false) do
  source 'https://rubygems.org'

  gem 'telegram-bot-ruby'
end

require 'telegram/bot'

token = ENV['DEBTS_BOT_TOKEN'] || raise('DEBTS_BOT_TOKEN env variable should be set')

FILE_PATH = './debts.txt'.freeze

def all_messages
  File.read(FILE_PATH) if File.exist?(FILE_PATH)
end

def add_debts(message)
  File.write(FILE_PATH, "#{message.from.first_name}:#{message.text.tr(':', ' ')}\n", mode: 'a')
end

def how_much
  return unless all_messages
  all_messages.split("\n").each_with_object(Hash.new(0)) do |msg, obj|
    name, text = msg.split(':')
    amount = text.match(/[\d\.]+/).to_a.first.to_f

    debtor = case name
             when /alexander/i then 'саша'
             when /vadim/i     then 'вадим'
             end

    debtor = case text
             when /\Aсаша/i  then 'саша'
             when /\Aвадим/i then 'вадим'
             else debtor
             end

    amount = case text
             when /взял|должен/i then amount
             when /отдал/i then -amount
             end

    obj[debtor] += amount
  end.inject('') do |str, (debtor, amount)|
    str << "#{debtor} должен #{amount}\n"
  end
end

Telegram::Bot::Client.run(token) do |bot|
  bot.listen do |message|
    send_msg = ->(text) { bot.api.send_message(chat_id: message.chat.id, text: text) unless text.strip.empty? }

    case message.text
    when /все/i
      send_msg.call(all_messages || 'долгов нет')
    when /взял|должен|отдал/i
      add_debts(message)
      send_msg.call('ок')
    when /че/i
      send_msg.call(how_much || 'ниче')
    when /очистить|кхуям/i
      send_msg.call([all_messages, "\n\n", how_much].join)
      File.delete(FILE_PATH) if File.exist?(FILE_PATH)
    when /команды/i
      send_msg.call('все, взял|должен|отдал, че, очистить|кхуям, команды')
    end
  end
end
