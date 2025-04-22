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
  @css = 'index.css'
  erb :index
end

get '/add' do
  erb :add
end

get '/:memo_id' do
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
