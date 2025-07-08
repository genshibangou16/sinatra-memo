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

class Memo
  attr_accessor :id, :title, :content, :timestamptz

  def initialize(title:, content:, id: SecureRandom.uuid, timestamptz: nil)
    @id = id
    @title = title
    @content = content
    @timestamptz = timestamptz
  end

  def save
    conn.exec('insert into memos (id, title, content) values ($1::uuid, $2::text, $3::text)', [@id, @title, @content])
  end

  def delete
    conn.exec('delete from memos where id = $1::uuid', [@id])
  end

  def update
    conn.exec('update memos set title = $1::text, content = $2::text where id = $3::uuid', [@title, @content, @id])
  end

  def self.all
    result = conn.exec('select * from memos')
    return [] if result.count.zero?

    result.map do |row|
      new(
        id: row['id'],
        title: row['title'],
        content: row['content'],
        timestamptz: row['timestamptz']
      )
    end
  end

  def self.find(id:)
    result = conn.exec('select * from memos where id = $1::uuid', [id])
    return nil if result.count.zero?

    new(
      id: result[0]['id'],
      title: result[0]['title'],
      content: result[0]['content'],
      timestamptz: result[0]['timestamptz']
    )
  end
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
  @memos = Memo.all
  erb :memos
end

post '/memos' do
  if params[:title].empty?
    warn_no_title(params)
  else
    @memo = Memo.new(title: params[:title], content: params[:content])
    @memo.save
    redirect "/memos/#{@memo.id}"
  end
end

get '/memos/new' do
  erb :new
end

get '/memos/' do
  redirect '/memos'
end

get '/memos/:memo_id' do
  @memo = Memo.find(id: params[:memo_id])

  if @memo.nil?
    status 404
    erb :not_found
  else
    erb :show
  end
end

delete '/memos/:memo_id' do
  @memo = Memo.find(id: params[:memo_id])

  if @memo.nil?
    status 404
    erb :not_found
  else
    @memo.delete
    redirect '/memos'
  end
end

patch '/memos/:memo_id' do
  @memo = Memo.find(id: params[:memo_id])

  if @memo.nil?
    status 404
    erb :not_found
  elsif params[:title].empty?
    warn_no_title(params)
  else
    @memo.title = params[:title]
    @memo.content = params[:content]
    @memo.update
    redirect "/memos/#{@memo.id}"
  end
end

get '/memos/:memo_id/edit' do
  @memo = Memo.find(id: params[:memo_id])

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
