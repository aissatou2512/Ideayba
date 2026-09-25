-- IDEAYBA : table unique « ideas » (type = project | small | tech).
-- Le contenu détaillé de chaque fiche (blocs du business plan, notes, statut, catégorie…) est dans la colonne JSON « data ».
create table if not exists public.ideas (
  user_id    uuid not null default auth.uid() references auth.users(id) on delete cascade,
  id         text not null,
  type       text not null check (type in ('project','small','tech')),
  title      text not null default '',
  data       jsonb not null default '{}'::jsonb,
  favorite   boolean not null default false,
  archived   boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  primary key (user_id, id)
);
create index if not exists ideas_user_type_idx    on public.ideas (user_id, type, archived);
create index if not exists ideas_user_updated_idx on public.ideas (user_id, updated_at desc);

create or replace function public.ideas_touch() returns trigger language plpgsql as $$
begin new.updated_at := now(); return new; end $$;
drop trigger if exists ideas_touch on public.ideas;
create trigger ideas_touch before update on public.ideas for each row execute function public.ideas_touch();

-- Sécurité : chaque utilisateur ne voit et ne modifie que ses propres lignes.
alter table public.ideas enable row level security;
revoke all on public.ideas from anon;
grant select, insert, update, delete on public.ideas to authenticated;
drop policy if exists ideas_select on public.ideas; drop policy if exists ideas_insert on public.ideas;
drop policy if exists ideas_update on public.ideas; drop policy if exists ideas_delete on public.ideas;
create policy ideas_select on public.ideas for select to authenticated using (user_id = (select auth.uid()));
create policy ideas_insert on public.ideas for insert to authenticated with check (user_id = (select auth.uid()));
create policy ideas_update on public.ideas for update to authenticated using (user_id = (select auth.uid())) with check (user_id = (select auth.uid()));
create policy ideas_delete on public.ideas for delete to authenticated using (user_id = (select auth.uid()));

-- ===== Stockage privé des images et fichiers joints (Supabase Storage) =====
insert into storage.buckets (id, name, public, file_size_limit)
values ('ideayba-files', 'ideayba-files', false, 10485760)
on conflict (id) do update set public = false, file_size_limit = 10485760;

-- Chemin des fichiers : <id utilisateur>/<id projet>/<fichier>. Seul le propriétaire du dossier y accède.
drop policy if exists ideayba_files_select on storage.objects; drop policy if exists ideayba_files_insert on storage.objects;
drop policy if exists ideayba_files_update on storage.objects; drop policy if exists ideayba_files_delete on storage.objects;
create policy ideayba_files_select on storage.objects for select to authenticated
  using (bucket_id = 'ideayba-files' and (storage.foldername(name))[1] = (select auth.uid())::text);
create policy ideayba_files_insert on storage.objects for insert to authenticated
  with check (bucket_id = 'ideayba-files' and (storage.foldername(name))[1] = (select auth.uid())::text);
create policy ideayba_files_update on storage.objects for update to authenticated
  using (bucket_id = 'ideayba-files' and (storage.foldername(name))[1] = (select auth.uid())::text)
  with check (bucket_id = 'ideayba-files' and (storage.foldername(name))[1] = (select auth.uid())::text);
create policy ideayba_files_delete on storage.objects for delete to authenticated
  using (bucket_id = 'ideayba-files' and (storage.foldername(name))[1] = (select auth.uid())::text);
