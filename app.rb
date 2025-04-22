# frozen_string_literal: true

require 'sinatra'
require 'sinatra/reloader'
require 'json'

before do
  file = File.read('./public/memo.json')
  parsed = JSON.parse(file)
  @memos = parsed.transform_values do |memo|
    memo.transform_keys(&:to_sym)
  end
end

get '/' do
  redirect '/memos'
end

get '/memos' do
  @css = 'memos.css'
  erb :memos
end

get '/memos/new' do
  erb :new
end

get '/memos/:memo_id' do
  memo_id = params[:memo_id]

  if @memos.key?(memo_id)
    @css = 'show.css'
    @memo = @memos[memo_id]
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
