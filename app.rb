# frozen_string_literal: true

require 'sinatra'
require 'sinatra/reloader'
require 'json'
require 'securerandom'
require 'date'

MEMOS_FILE_PATH = './public/memos.json'

before do
  parsed = JSON.load_file(MEMOS_FILE_PATH)
  @memos = parsed.transform_values do |memo|
    memo.transform_keys(&:to_sym)
  end
end

get '/' do
  redirect '/memos'
end

get '/memos' do
  @css = 'memos.css'
  @additional_button = { href: '/memos/new', text: '追加' }
  erb :memos
end

post '/memos' do
  uuid = SecureRandom.uuid
  @title = params[:title]
  @content = params[:content]
  @memos[uuid] = { title: @title, timestamp: DateTime.now.iso8601, content: @content }
  File.open(MEMOS_FILE_PATH, 'w') do |f|
    JSON.dump(@memos, f)
  end
  redirect "/memos/#{uuid}"
end

get '/memos/new' do
  @additional_button = { href: '/memos', text: '戻る' }
  @css = 'new.css'
  erb :new
end

get '/memos/' do
  redirect '/memos'
end

get '/memos/:memo_id' do
  memo_id = params[:memo_id]

  if @memos.key?(memo_id)
    @css = 'show.css'
    @memo = @memos[memo_id]
    @additional_button = { href: '/memos', text: '戻る' }
    erb :show
  else
    status 404
    erb :not_found
  end
end

not_found do
  status 404
  erb :not_found
end
