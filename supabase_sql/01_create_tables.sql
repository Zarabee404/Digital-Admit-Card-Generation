-- Enable UUID support
create extension if not exists "uuid-ossp";

-- =========================
-- STUDENTS TABLE
-- =========================
create table if not exists public.students (
  id uuid primary key default uuid_generate_v4(),
  auth_user_id uuid not null unique references auth.users(id) on delete cascade,

  name text not null,
  student_id text not null unique,
  email text not null unique,
  batch text not null,
  semester int not null check (semester between 1 and 12),

  role text not null default 'student' check (role = 'student'),

  created_at timestamptz not null default now()
);

-- =========================
-- ADMINS TABLE
-- =========================
create table if not exists public.admins (
  id uuid primary key default uuid_generate_v4(),
  auth_user_id uuid not null unique references auth.users(id) on delete cascade,

  name text not null,
  email text not null unique,

  role text not null default 'admin' check (role = 'admin'),

  created_at timestamptz not null default now()
);

-- =========================
-- COURSES TABLE
-- =========================
create table if not exists public.courses (
  id bigint generated always as identity primary key,

  semester int not null check (semester between 1 and 12),
  course_code text not null,
  course_title text not null,
  credit numeric(3,1) not null,

  created_at timestamptz not null default now(),

  unique (semester, course_code)
);

-- =========================
-- ADMIT CARD REQUESTS TABLE
-- =========================
create table if not exists public.admit_card_requests (
  id uuid primary key default uuid_generate_v4(),

  student_auth_id uuid not null references auth.users(id) on delete cascade,
  student_db_id uuid not null references public.students(id) on delete cascade,

  student_name text not null,
  student_id text not null,
  email text not null,
  batch text not null,
  semester int not null check (semester between 1 and 12),

  status text not null default 'pending'
    check (status in ('pending', 'approved', 'rejected')),

  submitted_on timestamptz not null default now(),
  approved_on timestamptz,

  created_at timestamptz not null default now(),

  unique (student_auth_id, semester)
);

-- =========================
-- ADMIT CARD REQUEST COURSES TABLE
-- =========================
create table if not exists public.admit_card_request_courses (
  id bigint generated always as identity primary key,

  request_id uuid not null references public.admit_card_requests(id) on delete cascade,
  course_id bigint not null references public.courses(id) on delete restrict,

  course_code text not null,
  course_title text not null,
  credit numeric(3,1) not null,

  created_at timestamptz not null default now(),

  unique (request_id, course_code)
);