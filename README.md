# sinatra-memo

簡単にホスト可能なWebメモアプリです。

# How to use

1. 作業PCの任意の作業ディレクトリにて`git clone`してください。

```bash
git clone https://github.com/genshibangou16/sinatra-memo.git
```

2. 取得したフォルダーに移動します。

```bash
cd sinatra-memo
```

3. `bundle`コマンドで必要なモジュールをインストールしてください。

```bash
bundle
```

4. データベースを作成します。

`PostgreSQL`がインストールし、ユーザーを作成してください。
次のコマンドでデータベースとテーブルを作成してください。

```bash
psql -U{username} -f db/01_create_database.sql
psql -U{username} -d fbc_memo_app -f db/02_create_table.sql
```

5. Webアプリを起動します。

```bash
bundle exec ruby app.rb
```

正常に起動されるとアプリにアクセスするURLが表示されます。

[http://127.0.0.1](http://127.0.0.1:4567)
