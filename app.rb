# frozen_string_literal: true

require 'sinatra'
require 'sinatra/reloader'
require 'sinatra/content_for'
require 'json'
require 'securerandom'
require 'date'
require 'pg'

def conn
  @conn ||= PG.connect(dbname: 'fbc_memo_app')
end

def insert_memo(id:, title:, content:)
  conn.exec('insert into memos (id, title, content) values ($1::uuid, $2::text, $3::text)', [id, title, content])
end

def select_memos
  result = conn.exec('select * from memos')
  return [] if result.count.zero?

  result.map do |row|
    {
      id: row['id'],
      title: row['title'],
      content: row['content'],
      timestamptz: row['timestamptz']
    }
  end
end

def select_memo(id:)
  result = conn.exec('select * from memos where id = $1::uuid', [id])
  return nil if result.count.zero?

  {
    id: result[0]['id'],
    title: result[0]['title'],
    content: result[0]['content'],
    timestamptz: result[0]['timestamptz']
  }
end

def update_memo(id:, title:, content:)
  conn.exec('update memos set title = $1::text, content = $2::text where id = $3::uuid', [title, content, id])
end

def delete_memo(id:)
  conn.exec('delete from memos where id = $1::uuid', [id])
end

def warn_no_title(params)
  status 422
  @error_message = 'タイトルは必須です。'
  @content = params[:content]
  erb :new
end

helpers do
  def h(text)
    Rack::Utils.escape_html(text)
  end
end

get '/' do
  redirect '/memos'
end

get '/memos' do
  @memos = select_memos
  erb :memos
end

post '/memos' do
  if params[:title].empty?
    warn_no_title(params)
  else
    uuid = SecureRandom.uuid
    title = params[:title]
    content = params[:content]
    insert_memo(id: uuid, title: title, content: content)
    redirect "/memos/#{uuid}"
  end
end

get '/memos/new' do
  erb :new
end

get '/memos/' do
  redirect '/memos'
end

get '/memos/:memo_id' do
  memo_id = params[:memo_id]
  @memo = select_memo(id: memo_id)

  if @memo.nil?
    status 404
    erb :not_found
  else
    erb :show
  end
end

delete '/memos/:memo_id' do
  memo_id = params[:memo_id]
  @memo = select_memo(id: memo_id)

  if @memo.nil?
    status 404
    erb :not_found
  else
    delete_memo(id: memo_id)
    redirect '/memos'
  end
end

patch '/memos/:memo_id' do
  memo_id = params[:memo_id]
  @memo = select_memo(id: memo_id)

  if @memo.nil?
    status 404
    erb :not_found
  elsif params[:title].empty?
    warn_no_title(params)
  else
    title = params[:title]
    content = params[:content]
    update_memo(id: memo_id, title: title, content: content)
    redirect "/memos/#{memo_id}"
  end
end

get '/memos/:memo_id/edit' do
  memo_id = params[:memo_id]
  @memo = select_memo(id: memo_id)

  if @memo.nil?
    status 404
    erb :not_found
  else
    erb :new
  end
end

get '/error' do
  erb :error
end

not_found do
  status 404
  erb :not_found
end
