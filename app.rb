# frozen_string_literal: true

require 'sinatra'
require 'sinatra/reloader'
require 'json'
require 'securerandom'
require 'date'

MEMOS_FILE_PATH = './public/memos.json'

def load_memos(path)
  return [] unless File.exist?(path) && !File.empty?(path)

  JSON.load_file(path, symbolize_names: true)
end

def save_memos(memos)
  File.open(MEMOS_FILE_PATH, 'w') do |f|
    JSON.dump({ memos: memos }, f)
  end
end

def find_memo_by_id(memos, id)
  memos.find { |memo| memo[:id] == id } || {}
end

def delete_memo_by_id(memos, id)
  memos.reject { |memo| memo[:id] == id }
end

helpers do
  def h(text)
    Rack::Utils.escape_html(text)
  end
end

before do
  @memos = load_memos(MEMOS_FILE_PATH)[:memos]
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
  redirect '/error' if params[:title].empty?

  uuid = SecureRandom.uuid
  title = params[:title]
  content = params[:content]
  @memos.push({ id: uuid, title: title, timestamp: DateTime.now.iso8601, content: content })
  save_memos(@memos)
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
  @memo = find_memo_by_id(@memos, memo_id)

  if @memo.empty?
    status 404
    erb :not_found
  else
    @css = 'show.css'
    @additional_button = { href: '/memos', text: 'ホーム' }
    erb :show
  end
end

delete '/memos/:memo_id' do
  memo_id = params[:memo_id]
  @memo = find_memo_by_id(@memos, memo_id)

  if @memo.empty?
    status 404
    erb :not_found
  else
    @memos = delete_memo_by_id(@memos, memo_id)
    save_memos(@memos)
    redirect '/memos'
  end
end

patch '/memos/:memo_id' do
  memo_id = params[:memo_id]
  @memo = find_memo_by_id(@memos, memo_id)

  if @memo.empty?
    status 404
    erb :not_found
  else
    redirect '/error' if params[:title].empty?

    title = params[:title]
    content = params[:content]
    @memo = { id: memo_id, title: title, timestamp: DateTime.now.iso8601, content: content }
    @memos = delete_memo_by_id(@memos, memo_id)
    @memos.push(@memo)
    save_memos(@memos)
    redirect "/memos/#{memo_id}"
  end
end

get '/memos/:memo_id/edit' do
  memo_id = params[:memo_id]
  @memo = find_memo_by_id(@memos, memo_id)

  if @memo.empty?
    status 404
    erb :not_found
  else
    @css = 'new.css'
    @additional_button = { href: "/memos/#{memo_id}", text: '戻る' }
    erb :new
  end
end

get '/error' do
  @additional_button = { href: '/memos', text: 'ホーム' }
  erb :error
end

not_found do
  status 404
  erb :not_found
end
