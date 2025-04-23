# frozen_string_literal: true

require 'sinatra'
require 'sinatra/reloader'
require 'json'
require 'securerandom'
require 'date'

MEMOS_FILE_PATH = './public/memos.json'

before do
  if File.exist?(MEMOS_FILE_PATH) && !File.empty?(MEMOS_FILE_PATH)
    parsed = JSON.load_file(MEMOS_FILE_PATH)
    @memos = parsed.transform_values do |memo|
      memo.transform_keys(&:to_sym)
    end
  else
    @memos = {}
  end
end

helpers do
  def h(text)
    Rack::Utils.escape_html(text)
  end

  def save_as_json(hash)
    File.open(MEMOS_FILE_PATH, 'w') do |f|
      JSON.dump(hash, f)
    end
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
  redirect '/error' if params[:title].empty?

  uuid = SecureRandom.uuid
  title = params[:title]
  content = params[:content]
  @memos[uuid] = { title: title, timestamp: DateTime.now.iso8601, content: content }
  save_as_json(@memos)
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
    @memo[:id] = memo_id
    @additional_button = { href: '/memos', text: 'ホーム' }
    erb :show
  else
    status 404
    erb :not_found
  end
end

delete '/memos/:memo_id' do
  memo_id = params[:memo_id]

  if @memos.key?(memo_id)
    @memos.delete(memo_id)
    save_as_json(@memos)
    redirect '/memos'
  else
    status 404
    erb :not_found
  end
end

patch '/memos/:memo_id' do
  memo_id = params[:memo_id]

  if @memos.key?(memo_id)
    redirect '/error' if params[:title].empty?

    title = params[:title]
    content = params[:content]
    @memos[memo_id] = { title: title, timestamp: DateTime.now.iso8601, content: content }
    save_as_json(@memos)
    redirect "/memos/#{memo_id}"
  else
    status 404
    erb :not_found
  end
end

get '/memos/:memo_id/edit' do
  memo_id = params[:memo_id]

  if @memos.key?(memo_id)
    @css = 'new.css'
    @memo = @memos[memo_id]
    @memo[:id] = memo_id
    @additional_button = { href: "/memos/#{memo_id}", text: '戻る' }
    erb :new
  else
    status 404
    erb :not_found
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
