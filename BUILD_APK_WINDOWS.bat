-- =============================================================
-- RapiKas Money Tracker Pro - Supabase Database Full Schema
-- Jalankan di Supabase Dashboard > SQL Editor > New Query > Run
-- =============================================================

-- Extensions
create extension if not exists pgcrypto;

-- =============================================================
-- 1. TABLES
-- =============================================================

create table if not exists public.profiles (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade unique,
  full_name text,
  avatar_url text,
  currency text not null default 'IDR',
  language text not null default 'id',
  theme text not null default 'system' check (theme in ('light', 'dark', 'system')),
  pin_enabled boolean not null default false,
  biometric_enabled boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.wallets (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  name text not null,
  type text not null default 'cash' check (type in ('cash', 'bank', 'ewallet', 'savings', 'credit_card', 'investment', 'other')),
  balance numeric(14,2) not null default 0,
  initial_balance numeric(14,2) not null default 0,
  icon text default 'wallet',
  color text default '#10B981',
  is_archived boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.categories (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references auth.users(id) on delete cascade,
  name text not null,
  type text not null check (type in ('income', 'expense')),
  icon text default 'category',
  color text default '#10B981',
  is_default boolean not null default false,
  sort_order int not null default 0,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint default_category_owner_check check (
    (is_default = true and user_id is null) or (is_default = false and user_id is not null)
  )
);

create table if not exists public.transactions (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  wallet_id uuid not null references public.wallets(id) on delete restrict,
  category_id uuid references public.categories(id) on delete set null,
  type text not null check (type in ('income', 'expense')),
  amount numeric(14,2) not null check (amount > 0),
  title text,
  note text,
  merchant text,
  payment_method text,
  transaction_date timestamptz not null default now(),
  receipt_url text,
  location text,
  tags text[] not null default '{}',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.transfers (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  from_wallet_id uuid not null references public.wallets(id) on delete restrict,
  to_wallet_id uuid not null references public.wallets(id) on delete restrict,
  amount numeric(14,2) not null check (amount > 0),
  fee numeric(14,2) not null default 0 check (fee >= 0),
  note text,
  transfer_date timestamptz not null default now(),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint transfer_wallets_must_be_different check (from_wallet_id <> to_wallet_id)
);

create table if not exists public.budgets (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  category_id uuid not null references public.categories(id) on delete cascade,
  amount numeric(14,2) not null check (amount > 0),
  period text not null default 'monthly' check (period in ('weekly', 'monthly', 'yearly')),
  start_date date not null,
  end_date date not null,
  alert_percent int not null default 80 check (alert_percent between 1 and 100),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint budget_date_check check (end_date >= start_date)
);

create table if not exists public.goals (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  title text not null,
  target_amount numeric(14,2) not null check (target_amount > 0),
  current_amount numeric(14,2) not null default 0 check (current_amount >= 0),
  target_date date,
  icon text default 'flag',
  color text default '#10B981',
  status text not null default 'active' check (status in ('active', 'completed', 'cancelled')),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.goal_contributions (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  goal_id uuid not null references public.goals(id) on delete cascade,
  wallet_id uuid references public.wallets(id) on delete set null,
  amount numeric(14,2) not null check (amount > 0),
  note text,
  contribution_date timestamptz not null default now(),
  created_at timestamptz not null default now()
);

create table if not exists public.debts (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  person_name text not null,
  type text not null check (type in ('debt', 'receivable')),
  amount numeric(14,2) not null check (amount > 0),
  paid_amount numeric(14,2) not null default 0 check (paid_amount >= 0),
  due_date date,
  status text not null default 'unpaid' check (status in ('unpaid', 'partial', 'paid')),
  note text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.debt_payments (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  debt_id uuid not null references public.debts(id) on delete cascade,
  wallet_id uuid references public.wallets(id) on delete set null,
  amount numeric(14,2) not null check (amount > 0),
  payment_date timestamptz not null default now(),
  note text,
  created_at timestamptz not null default now()
);

create table if not exists public.bills (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  title text not null,
  amount numeric(14,2) not null check (amount > 0),
  due_date date not null,
  repeat_type text not null default 'monthly' check (repeat_type in ('none', 'daily', 'weekly', 'monthly', 'yearly')),
  status text not null default 'unpaid' check (status in ('unpaid', 'paid', 'skipped')),
  category_id uuid references public.categories(id) on delete set null,
  wallet_id uuid references public.wallets(id) on delete set null,
  reminder_enabled boolean not null default true,
  reminder_days_before int not null default 3 check (reminder_days_before >= 0),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.recurring_transactions (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  wallet_id uuid not null references public.wallets(id) on delete cascade,
  category_id uuid references public.categories(id) on delete set null,
  type text not null check (type in ('income', 'expense')),
  amount numeric(14,2) not null check (amount > 0),
  title text not null,
  note text,
  repeat_type text not null check (repeat_type in ('daily', 'weekly', 'monthly', 'yearly')),
  next_run_date date not null,
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.attachments (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  transaction_id uuid references public.transactions(id) on delete cascade,
  file_url text not null,
  file_type text,
  file_name text,
  file_size int,
  created_at timestamptz not null default now()
);

create table if not exists public.ai_insights (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  insight_type text not null check (insight_type in ('summary', 'warning', 'saving_tip', 'budget_tip', 'prediction', 'anomaly')),
  title text not null,
  content text not null,
  period text,
  is_read boolean not null default false,
  created_at timestamptz not null default now()
);

-- =============================================================
-- 2. UNIQUE INDEXES + PERFORMANCE INDEXES
-- =============================================================

create unique index if not exists uniq_user_wallet_name on public.wallets(user_id, lower(name)) where is_archived = false;
create unique index if not exists uniq_default_category_name_type on public.categories(lower(name), type) where user_id is null;
create unique index if not exists uniq_user_category_name_type on public.categories(user_id, lower(name), type) where user_id is not null;

create index if not exists idx_profiles_user_id on public.profiles(user_id);
create index if not exists idx_wallets_user_id on public.wallets(user_id);
create index if not exists idx_categories_user_id_type on public.categories(user_id, type);
create index if not exists idx_transactions_user_id_date on public.transactions(user_id, transaction_date desc);
create index if not exists idx_transactions_wallet_id on public.transactions(wallet_id);
create index if not exists idx_transactions_category_id on public.transactions(category_id);
create index if not exists idx_transfers_user_id_date on public.transfers(user_id, transfer_date desc);
create index if not exists idx_budgets_user_id on public.budgets(user_id);
create index if not exists idx_goals_user_id on public.goals(user_id);
create index if not exists idx_debts_user_id on public.debts(user_id);
create index if not exists idx_bills_user_id_due_date on public.bills(user_id, due_date);
create index if not exists idx_ai_insights_user_id_created_at on public.ai_insights(user_id, created_at desc);

-- =============================================================
-- 3. FUNCTIONS + TRIGGERS
-- =============================================================

create or replace function public.set_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

drop trigger if exists trg_profiles_updated_at on public.profiles;
create trigger trg_profiles_updated_at before update on public.profiles
for each row execute function public.set_updated_at();

drop trigger if exists trg_wallets_updated_at on public.wallets;
create trigger trg_wallets_updated_at before update on public.wallets
for each row execute function public.set_updated_at();

drop trigger if exists trg_categories_updated_at on public.categories;
create trigger trg_categories_updated_at before update on public.categories
for each row execute function public.set_updated_at();

drop trigger if exists trg_transactions_updated_at on public.transactions;
create trigger trg_transactions_updated_at before update on public.transactions
for each row execute function public.set_updated_at();

drop trigger if exists trg_transfers_updated_at on public.transfers;
create trigger trg_transfers_updated_at before update on public.transfers
for each row execute function public.set_updated_at();

drop trigger if exists trg_budgets_updated_at on public.budgets;
create trigger trg_budgets_updated_at before update on public.budgets
for each row execute function public.set_updated_at();

drop trigger if exists trg_goals_updated_at on public.goals;
create trigger trg_goals_updated_at before update on public.goals
for each row execute function public.set_updated_at();

drop trigger if exists trg_debts_updated_at on public.debts;
create trigger trg_debts_updated_at before update on public.debts
for each row execute function public.set_updated_at();

drop trigger if exists trg_bills_updated_at on public.bills;
create trigger trg_bills_updated_at before update on public.bills
for each row execute function public.set_updated_at();

drop trigger if exists trg_recurring_transactions_updated_at on public.recurring_transactions;
create trigger trg_recurring_transactions_updated_at before update on public.recurring_transactions
for each row execute function public.set_updated_at();

-- Auto-create profile after Supabase Auth signup
create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  insert into public.profiles (user_id, full_name, avatar_url)
  values (
    new.id,
    coalesce(new.raw_user_meta_data ->> 'full_name', new.raw_user_meta_data ->> 'name'),
    new.raw_user_meta_data ->> 'avatar_url'
  )
  on conflict (user_id) do nothing;

  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
after insert on auth.users
for each row execute function public.handle_new_user();

-- Validate owner of related records
create or replace function public.validate_transaction_owner()
returns trigger
language plpgsql
as $$
begin
  if not exists (
    select 1 from public.wallets w
    where w.id = new.wallet_id and w.user_id = new.user_id
  ) then
    raise exception 'Wallet does not belong to this user';
  end if;

  if new.category_id is not null and not exists (
    select 1 from public.categories c
    where c.id = new.category_id and (c.user_id = new.user_id or c.user_id is null)
  ) then
    raise exception 'Category does not belong to this user';
  end if;

  return new;
end;
$$;

drop trigger if exists trg_validate_transaction_owner on public.transactions;
create trigger trg_validate_transaction_owner
before insert or update on public.transactions
for each row execute function public.validate_transaction_owner();

create or replace function public.validate_transfer_owner()
returns trigger
language plpgsql
as $$
begin
  if not exists (
    select 1 from public.wallets w
    where w.id = new.from_wallet_id and w.user_id = new.user_id
  ) then
    raise exception 'Source wallet does not belong to this user';
  end if;

  if not exists (
    select 1 from public.wallets w
    where w.id = new.to_wallet_id and w.user_id = new.user_id
  ) then
    raise exception 'Destination wallet does not belong to this user';
  end if;

  return new;
end;
$$;

drop trigger if exists trg_validate_transfer_owner on public.transfers;
create trigger trg_validate_transfer_owner
before insert or update on public.transfers
for each row execute function public.validate_transfer_owner();

-- Automatic wallet balance adjustment
create or replace function public.apply_transaction_to_wallet(p_wallet_id uuid, p_type text, p_amount numeric, p_direction int)
returns void
language plpgsql
as $$
begin
  if p_type = 'income' then
    update public.wallets set balance = balance + (p_amount * p_direction) where id = p_wallet_id;
  elsif p_type = 'expense' then
    update public.wallets set balance = balance - (p_amount * p_direction) where id = p_wallet_id;
  end if;
end;
$$;

create or replace function public.handle_transaction_wallet_balance()
returns trigger
language plpgsql
as $$
begin
  if tg_op = 'INSERT' then
    perform public.apply_transaction_to_wallet(new.wallet_id, new.type, new.amount, 1);
    return new;
  elsif tg_op = 'UPDATE' then
    perform public.apply_transaction_to_wallet(old.wallet_id, old.type, old.amount, -1);
    perform public.apply_transaction_to_wallet(new.wallet_id, new.type, new.amount, 1);
    return new;
  elsif tg_op = 'DELETE' then
    perform public.apply_transaction_to_wallet(old.wallet_id, old.type, old.amount, -1);
    return old;
  end if;

  return null;
end;
$$;

drop trigger if exists trg_transaction_wallet_balance on public.transactions;
create trigger trg_transaction_wallet_balance
after insert or update or delete on public.transactions
for each row execute function public.handle_transaction_wallet_balance();

create or replace function public.handle_transfer_wallet_balance()
returns trigger
language plpgsql
as $$
begin
  if tg_op = 'INSERT' then
    update public.wallets set balance = balance - new.amount - new.fee where id = new.from_wallet_id;
    update public.wallets set balance = balance + new.amount where id = new.to_wallet_id;
    return new;
  elsif tg_op = 'UPDATE' then
    update public.wallets set balance = balance + old.amount + old.fee where id = old.from_wallet_id;
    update public.wallets set balance = balance - old.amount where id = old.to_wallet_id;
    update public.wallets set balance = balance - new.amount - new.fee where id = new.from_wallet_id;
    update public.wallets set balance = balance + new.amount where id = new.to_wallet_id;
    return new;
  elsif tg_op = 'DELETE' then
    update public.wallets set balance = balance + old.amount + old.fee where id = old.from_wallet_id;
    update public.wallets set balance = balance - old.amount where id = old.to_wallet_id;
    return old;
  end if;

  return null;
end;
$$;

drop trigger if exists trg_transfer_wallet_balance on public.transfers;
create trigger trg_transfer_wallet_balance
after insert or update or delete on public.transfers
for each row execute function public.handle_transfer_wallet_balance();

-- Goal contribution updates current_amount
create or replace function public.handle_goal_contribution_total()
returns trigger
language plpgsql
as $$
begin
  if tg_op = 'INSERT' then
    update public.goals
    set current_amount = current_amount + new.amount,
        status = case when current_amount + new.amount >= target_amount then 'completed' else status end
    where id = new.goal_id;
    return new;
  elsif tg_op = 'DELETE' then
    update public.goals
    set current_amount = greatest(0, current_amount - old.amount),
        status = case when greatest(0, current_amount - old.amount) < target_amount and status = 'completed' then 'active' else status end
    where id = old.goal_id;
    return old;
  elsif tg_op = 'UPDATE' then
    update public.goals
    set current_amount = greatest(0, current_amount - old.amount + new.amount),
        status = case when greatest(0, current_amount - old.amount + new.amount) >= target_amount then 'completed' else 'active' end
    where id = new.goal_id;
    return new;
  end if;

  return null;
end;
$$;

drop trigger if exists trg_goal_contribution_total on public.goal_contributions;
create trigger trg_goal_contribution_total
after insert or update or delete on public.goal_contributions
for each row execute function public.handle_goal_contribution_total();

-- Debt payments update debt status
create or replace function public.handle_debt_payment_total()
returns trigger
language plpgsql
as $$
declare
  v_debt_id uuid;
  v_total_paid numeric(14,2);
  v_amount numeric(14,2);
begin
  v_debt_id := coalesce(new.debt_id, old.debt_id);

  select coalesce(sum(amount), 0) into v_total_paid
  from public.debt_payments
  where debt_id = v_debt_id;

  select amount into v_amount from public.debts where id = v_debt_id;

  update public.debts
  set paid_amount = v_total_paid,
      status = case
        when v_total_paid <= 0 then 'unpaid'
        when v_total_paid < v_amount then 'partial'
        else 'paid'
      end
  where id = v_debt_id;

  return coalesce(new, old);
end;
$$;

drop trigger if exists trg_debt_payment_total on public.debt_payments;
create trigger trg_debt_payment_total
after insert or update or delete on public.debt_payments
for each row execute function public.handle_debt_payment_total();

-- =============================================================
-- 4. VIEWS FOR DASHBOARD/REPORT
-- =============================================================

create or replace view public.v_monthly_summary
with (security_invoker = true)
as
select
  user_id,
  date_trunc('month', transaction_date)::date as month,
  coalesce(sum(amount) filter (where type = 'income'), 0) as total_income,
  coalesce(sum(amount) filter (where type = 'expense'), 0) as total_expense,
  coalesce(sum(amount) filter (where type = 'income'), 0) - coalesce(sum(amount) filter (where type = 'expense'), 0) as net_cashflow
from public.transactions
group by user_id, date_trunc('month', transaction_date)::date;

create or replace view public.v_category_spending
with (security_invoker = true)
as
select
  t.user_id,
  t.category_id,
  c.name as category_name,
  c.icon,
  c.color,
  date_trunc('month', t.transaction_date)::date as month,
  sum(t.amount) as total_amount
from public.transactions t
left join public.categories c on c.id = t.category_id
where t.type = 'expense'
group by t.user_id, t.category_id, c.name, c.icon, c.color, date_trunc('month', t.transaction_date)::date;

-- =============================================================
-- 5. ROW LEVEL SECURITY
-- =============================================================

alter table public.profiles enable row level security;
alter table public.wallets enable row level security;
alter table public.categories enable row level security;
alter table public.transactions enable row level security;
alter table public.transfers enable row level security;
alter table public.budgets enable row level security;
alter table public.goals enable row level security;
alter table public.goal_contributions enable row level security;
alter table public.debts enable row level security;
alter table public.debt_payments enable row level security;
alter table public.bills enable row level security;
alter table public.recurring_transactions enable row level security;
alter table public.attachments enable row level security;
alter table public.ai_insights enable row level security;

-- Drop old policies if re-running this SQL
drop policy if exists profiles_select_own on public.profiles;
drop policy if exists profiles_insert_own on public.profiles;
drop policy if exists profiles_update_own on public.profiles;
drop policy if exists profiles_delete_own on public.profiles;

drop policy if exists wallets_all_own on public.wallets;
drop policy if exists categories_select_own_or_default on public.categories;
drop policy if exists categories_insert_own on public.categories;
drop policy if exists categories_update_own on public.categories;
drop policy if exists categories_delete_own on public.categories;
drop policy if exists transactions_all_own on public.transactions;
drop policy if exists transfers_all_own on public.transfers;
drop policy if exists budgets_all_own on public.budgets;
drop policy if exists goals_all_own on public.goals;
drop policy if exists goal_contributions_all_own on public.goal_contributions;
drop policy if exists debts_all_own on public.debts;
drop policy if exists debt_payments_all_own on public.debt_payments;
drop policy if exists bills_all_own on public.bills;
drop policy if exists recurring_transactions_all_own on public.recurring_transactions;
drop policy if exists attachments_all_own on public.attachments;
drop policy if exists ai_insights_all_own on public.ai_insights;

-- Profiles
create policy profiles_select_own on public.profiles
for select using (auth.uid() = user_id);

create policy profiles_insert_own on public.profiles
for insert with check (auth.uid() = user_id);

create policy profiles_update_own on public.profiles
for update using (auth.uid() = user_id) with check (auth.uid() = user_id);

create policy profiles_delete_own on public.profiles
for delete using (auth.uid() = user_id);

-- Own data policies
create policy wallets_all_own on public.wallets
for all using (auth.uid() = user_id) with check (auth.uid() = user_id);

create policy categories_select_own_or_default on public.categories
for select using (user_id is null or auth.uid() = user_id);

create policy categories_insert_own on public.categories
for insert with check (auth.uid() = user_id and is_default = false);

create policy categories_update_own on public.categories
for update using (auth.uid() = user_id and is_default = false) with check (auth.uid() = user_id and is_default = false);

create policy categories_delete_own on public.categories
for delete using (auth.uid() = user_id and is_default = false);

create policy transactions_all_own on public.transactions
for all using (auth.uid() = user_id) with check (auth.uid() = user_id);

create policy transfers_all_own on public.transfers
for all using (auth.uid() = user_id) with check (auth.uid() = user_id);

create policy budgets_all_own on public.budgets
for all using (auth.uid() = user_id) with check (auth.uid() = user_id);

create policy goals_all_own on public.goals
for all using (auth.uid() = user_id) with check (auth.uid() = user_id);

create policy goal_contributions_all_own on public.goal_contributions
for all using (auth.uid() = user_id) with check (auth.uid() = user_id);

create policy debts_all_own on public.debts
for all using (auth.uid() = user_id) with check (auth.uid() = user_id);

create policy debt_payments_all_own on public.debt_payments
for all using (auth.uid() = user_id) with check (auth.uid() = user_id);

create policy bills_all_own on public.bills
for all using (auth.uid() = user_id) with check (auth.uid() = user_id);

create policy recurring_transactions_all_own on public.recurring_transactions
for all using (auth.uid() = user_id) with check (auth.uid() = user_id);

create policy attachments_all_own on public.attachments
for all using (auth.uid() = user_id) with check (auth.uid() = user_id);

create policy ai_insights_all_own on public.ai_insights
for all using (auth.uid() = user_id) with check (auth.uid() = user_id);

-- =============================================================
-- 6. STORAGE BUCKET FOR RECEIPTS
-- =============================================================

insert into storage.buckets (id, name, public)
values ('receipts', 'receipts', false)
on conflict (id) do nothing;

drop policy if exists receipts_select_own on storage.objects;
drop policy if exists receipts_insert_own on storage.objects;
drop policy if exists receipts_update_own on storage.objects;
drop policy if exists receipts_delete_own on storage.objects;

-- Recommended path format from app: {user_id}/{transaction_id}/{filename}
create policy receipts_select_own on storage.objects
for select using (
  bucket_id = 'receipts' and (storage.foldername(name))[1] = auth.uid()::text
);

create policy receipts_insert_own on storage.objects
for insert with check (
  bucket_id = 'receipts' and (storage.foldername(name))[1] = auth.uid()::text
);

create policy receipts_update_own on storage.objects
for update using (
  bucket_id = 'receipts' and (storage.foldername(name))[1] = auth.uid()::text
) with check (
  bucket_id = 'receipts' and (storage.foldername(name))[1] = auth.uid()::text
);

create policy receipts_delete_own on storage.objects
for delete using (
  bucket_id = 'receipts' and (storage.foldername(name))[1] = auth.uid()::text
);

-- =============================================================
-- 7. DEFAULT CATEGORIES
-- =============================================================

insert into public.categories (name, type, icon, color, is_default, sort_order)
values
  ('Gaji', 'income', 'briefcase', '#22C55E', true, 1),
  ('Usaha', 'income', 'store', '#14B8A6', true, 2),
  ('Bonus', 'income', 'gift', '#84CC16', true, 3),
  ('Hadiah', 'income', 'sparkles', '#A3E635', true, 4),
  ('Investasi', 'income', 'trending-up', '#0EA5E9', true, 5),

  ('Makanan', 'expense', 'utensils', '#F97316', true, 1),
  ('Transportasi', 'expense', 'car', '#3B82F6', true, 2),
  ('Belanja', 'expense', 'shopping-bag', '#A855F7', true, 3),
  ('Pendidikan', 'expense', 'graduation-cap', '#06B6D4', true, 4),
  ('Kesehatan', 'expense', 'heart-pulse', '#EF4444', true, 5),
  ('Sedekah', 'expense', 'hand-heart', '#10B981', true, 6),
  ('Tagihan', 'expense', 'receipt', '#F43F5E', true, 7),
  ('Cicilan', 'expense', 'calendar-clock', '#64748B', true, 8),
  ('Hiburan', 'expense', 'gamepad-2', '#EC4899', true, 9),
  ('Rumah', 'expense', 'home', '#8B5CF6', true, 10),
  ('Internet', 'expense', 'wifi', '#0EA5E9', true, 11),
  ('Lainnya', 'expense', 'circle-ellipsis', '#71717A', true, 99)
on conflict do nothing;

-- =============================================================
-- 8. USEFUL NOTES
-- =============================================================
-- 1) Setelah menjalankan SQL ini, aktifkan Auth provider di Supabase Auth.
-- 2) Simpan Supabase Project URL dan anon public key ke file .env aplikasi Flutter.
-- 3) Untuk upload struk, gunakan path storage: userId/transactionId/filename.jpg
-- 4) Jangan taruh service_role key di aplikasi Android.
-- =============================================================
-- =============================================================
-- RapiKas Money Tracker Pro - Multi-Currency / Kurs Module
-- Jalankan setelah schema utama jika project Anda sudah pernah dibuat.
-- Jika Anda memakai schema.sql dari paket ini, module ini juga sudah ditambahkan di bawah.
-- =============================================================

-- 1. Tambahan kolom mata uang untuk tabel utama
alter table public.wallets
  add column if not exists currency_code text not null default 'IDR';

alter table public.transactions
  add column if not exists currency_code text not null default 'IDR',
  add column if not exists exchange_rate_to_base numeric(18,8) not null default 1,
  add column if not exists base_currency_code text not null default 'IDR',
  add column if not exists base_amount numeric(18,2);

alter table public.transfers
  add column if not exists from_currency_code text not null default 'IDR',
  add column if not exists to_currency_code text not null default 'IDR',
  add column if not exists exchange_rate numeric(18,8) not null default 1;

alter table public.budgets
  add column if not exists currency_code text not null default 'IDR',
  add column if not exists base_currency_code text not null default 'IDR',
  add column if not exists base_amount numeric(18,2);

alter table public.goals
  add column if not exists currency_code text not null default 'IDR',
  add column if not exists base_currency_code text not null default 'IDR',
  add column if not exists base_target_amount numeric(18,2),
  add column if not exists base_current_amount numeric(18,2);

-- 2. Master mata uang yang didukung
create table if not exists public.supported_currencies (
  code text primary key,
  name text not null,
  country text,
  symbol text,
  decimal_digits int not null default 2,
  is_popular boolean not null default false,
  sort_order int not null default 999,
  created_at timestamptz not null default now()
);

-- 3. Kurs harian terhadap IDR
create table if not exists public.currency_rates (
  id uuid primary key default gen_random_uuid(),
  base_code text not null default 'IDR',
  currency_code text not null references public.supported_currencies(code) on delete cascade,
  buy_rate numeric(18,8) not null check (buy_rate > 0),
  sell_rate numeric(18,8) not null check (sell_rate > 0),
  mid_rate numeric(18,8) generated always as ((buy_rate + sell_rate) / 2) stored,
  rate_date date not null default current_date,
  provider text not null default 'manual',
  is_manual boolean not null default false,
  raw_payload jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (base_code, currency_code, rate_date, provider)
);

-- 4. Preferensi kurs per user
create table if not exists public.user_currency_preferences (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade unique,
  base_currency_code text not null default 'IDR' references public.supported_currencies(code),
  favorite_currency_codes text[] not null default array['USD','EUR','SAR','SGD','MYR'],
  auto_update_rates boolean not null default true,
  rate_provider text not null default 'frankfurter',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

-- 5. Seed currencies populer + beberapa mata uang umum
insert into public.supported_currencies (code, name, country, symbol, decimal_digits, is_popular, sort_order)
values
  ('IDR','Rupiah Indonesia','Indonesia','Rp',0,true,1),
  ('USD','US Dollar','Amerika Serikat','$',2,true,2),
  ('EUR','Euro','Uni Eropa','€',2,true,3),
  ('SAR','Saudi Riyal','Arab Saudi','﷼',2,true,4),
  ('SGD','Singapore Dollar','Singapura','S$',2,true,5),
  ('MYR','Malaysian Ringgit','Malaysia','RM',2,true,6),
  ('JPY','Japanese Yen','Jepang','¥',0,true,7),
  ('GBP','Pound Sterling','Inggris','£',2,true,8),
  ('AUD','Australian Dollar','Australia','A$',2,true,9),
  ('AED','UAE Dirham','Uni Emirat Arab','د.إ',2,true,10),
  ('CNY','Chinese Yuan','Tiongkok','¥',2,true,11),
  ('KRW','South Korean Won','Korea Selatan','₩',0,true,12),
  ('THB','Thai Baht','Thailand','฿',2,true,13),
  ('CHF','Swiss Franc','Swiss','CHF',2,false,14),
  ('CAD','Canadian Dollar','Kanada','C$',2,false,15),
  ('HKD','Hong Kong Dollar','Hong Kong','HK$',2,false,16),
  ('INR','Indian Rupee','India','₹',2,false,17),
  ('PHP','Philippine Peso','Filipina','₱',2,false,18),
  ('VND','Vietnamese Dong','Vietnam','₫',0,false,19),
  ('TRY','Turkish Lira','Turki','₺',2,false,20)
on conflict (code) do update set
  name = excluded.name,
  country = excluded.country,
  symbol = excluded.symbol,
  decimal_digits = excluded.decimal_digits,
  is_popular = excluded.is_popular,
  sort_order = excluded.sort_order;

-- 6. Seed kurs contoh. Untuk production, isi otomatis dari Edge Function / API provider.
insert into public.currency_rates (base_code, currency_code, buy_rate, sell_rate, rate_date, provider, is_manual)
values
  ('IDR','IDR',1,1,current_date,'base',false),
  ('IDR','USD',16150,16300,current_date,'sample',true),
  ('IDR','EUR',17450,17700,current_date,'sample',true),
  ('IDR','GBP',20300,20650,current_date,'sample',true),
  ('IDR','JPY',103,107,current_date,'sample',true),
  ('IDR','SAR',4300,4380,current_date,'sample',true),
  ('IDR','AED',4380,4460,current_date,'sample',true),
  ('IDR','SGD',11800,12050,current_date,'sample',true),
  ('IDR','MYR',3400,3500,current_date,'sample',true),
  ('IDR','AUD',10450,10750,current_date,'sample',true),
  ('IDR','CAD',11800,12100,current_date,'sample',true),
  ('IDR','CHF',18500,19050,current_date,'sample',true),
  ('IDR','CNY',2210,2270,current_date,'sample',true),
  ('IDR','HKD',2050,2110,current_date,'sample',true),
  ('IDR','KRW',11.3,12.1,current_date,'sample',true),
  ('IDR','THB',440,465,current_date,'sample',true),
  ('IDR','INR',190,200,current_date,'sample',true),
  ('IDR','PHP',280,292,current_date,'sample',true),
  ('IDR','VND',0.61,0.67,current_date,'sample',true),
  ('IDR','TRY',485,520,current_date,'sample',true)
on conflict (base_code, currency_code, rate_date, provider) do update set
  buy_rate = excluded.buy_rate,
  sell_rate = excluded.sell_rate,
  is_manual = excluded.is_manual,
  updated_at = now();

-- 7. View untuk kurs terbaru per currency
create or replace view public.v_latest_currency_rates as
select distinct on (currency_code)
  currency_code,
  base_code,
  buy_rate,
  sell_rate,
  mid_rate,
  rate_date,
  provider,
  is_manual,
  updated_at
from public.currency_rates
order by currency_code, rate_date desc, updated_at desc;

-- 8. View dompet dengan nilai setara IDR
create or replace view public.v_wallets_with_base_value as
select
  w.*,
  coalesce(r.mid_rate, 1) as exchange_rate_to_idr,
  round(w.balance * coalesce(r.mid_rate, 1), 2) as balance_idr
from public.wallets w
left join public.v_latest_currency_rates r on r.currency_code = w.currency_code;

-- 9. Trigger updated_at untuk tabel kurs
create or replace function public.set_updated_at()
returns trigger language plpgsql as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

drop trigger if exists trg_currency_rates_updated_at on public.currency_rates;
create trigger trg_currency_rates_updated_at before update on public.currency_rates
for each row execute function public.set_updated_at();

drop trigger if exists trg_user_currency_preferences_updated_at on public.user_currency_preferences;
create trigger trg_user_currency_preferences_updated_at before update on public.user_currency_preferences
for each row execute function public.set_updated_at();

-- 10. RLS
alter table public.supported_currencies enable row level security;
alter table public.currency_rates enable row level security;
alter table public.user_currency_preferences enable row level security;

drop policy if exists supported_currencies_select_all on public.supported_currencies;
drop policy if exists currency_rates_select_all on public.currency_rates;
drop policy if exists user_currency_preferences_all_own on public.user_currency_preferences;

create policy supported_currencies_select_all on public.supported_currencies
for select using (true);

create policy currency_rates_select_all on public.currency_rates
for select using (true);

create policy user_currency_preferences_all_own on public.user_currency_preferences
for all using (auth.uid() = user_id) with check (auth.uid() = user_id);

-- 11. Catatan:
-- - currency_rates sengaja bisa dibaca semua user, karena data kurs bukan data pribadi.
-- - Insert/update kurs sebaiknya dilakukan server-side via Supabase Edge Function memakai service role.
-- - Jangan menaruh service_role key di APK.
-- =============================================================
