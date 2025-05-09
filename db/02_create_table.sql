-- memosテーブル作成
create table memos (
    id uuid primary key default gen_random_uuid(),
    title text not null,
    content text default '',
    created_at timestamptz not null default now()
);
