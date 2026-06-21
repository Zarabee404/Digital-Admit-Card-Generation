-- HELPER FUNCTION

create or replace function public.is_admin()
returns boolean
language sql
security definer
set search_path = public
as $$
  select exists (
    select 1
    from public.admins
    where auth_user_id = auth.uid()
  );
$$;

-- HELPER FUNCTION

create or replace function public.is_admin()
returns boolean
language sql
security definer
set search_path = public
as $$
  select exists (
    select 1
    from public.admins
    where auth_user_id = auth.uid()
  );
$$;

-- HELPER FUNCTION

create or replace function public.is_admin()
returns boolean
language sql
security definer
set search_path = public
as $$
  select exists (
    select 1
    from public.admins
    where auth_user_id = auth.uid()
  );
$$;


-- STUDENTS POLICIES


drop policy if exists "Students can read own profile" on public.students;
create policy "Students can read own profile"
on public.students
for select
to authenticated
using (
  auth_user_id = auth.uid()
);

drop policy if exists "Students can insert own profile" on public.students;
create policy "Students can insert own profile"
on public.students
for insert
to authenticated
with check (
  auth_user_id = auth.uid()
);

drop policy if exists "Admins can read all students" on public.students;
create policy "Admins can read all students"
on public.students
for select
to authenticated
using (
  public.is_admin()
);


-- ADMINS POLICIES


drop policy if exists "Admins can read own admin profile" on public.admins;
create policy "Admins can read own admin profile"
on public.admins
for select
to authenticated
using (
  auth_user_id = auth.uid()
);


-- COURSES POLICIES

drop policy if exists "Authenticated users can read courses" on public.courses;
create policy "Authenticated users can read courses"
on public.courses
for select
to authenticated
using (
  true
);

drop policy if exists "Admins can manage courses" on public.courses;
create policy "Admins can manage courses"
on public.courses
for all
to authenticated
using (
  public.is_admin()
)
with check (
  public.is_admin()
);


-- ADMIT CARD REQUESTS POLICIES


drop policy if exists "Students can read own admit card requests" on public.admit_card_requests;
create policy "Students can read own admit card requests"
on public.admit_card_requests
for select
to authenticated
using (
  student_auth_id = auth.uid()
);

drop policy if exists "Students can create own admit card request" on public.admit_card_requests;
create policy "Students can create own admit card request"
on public.admit_card_requests
for insert
to authenticated
with check (
  student_auth_id = auth.uid()
);

drop policy if exists "Admins can read all admit card requests" on public.admit_card_requests;
create policy "Admins can read all admit card requests"
on public.admit_card_requests
for select
to authenticated
using (
  public.is_admin()
);

drop policy if exists "Admins can update admit card requests" on public.admit_card_requests;
create policy "Admins can update admit card requests"
on public.admit_card_requests
for update
to authenticated
using (
  public.is_admin()
)
with check (
  public.is_admin()
);


-- ADMIT CARD REQUEST COURSES POLICIES


drop policy if exists "Students can read own request courses" on public.admit_card_request_courses;
create policy "Students can read own request courses"
on public.admit_card_request_courses
for select
to authenticated
using (
  exists (
    select 1
    from public.admit_card_requests r
    where r.id = admit_card_request_courses.request_id
    and r.student_auth_id = auth.uid()
  )
);

drop policy if exists "Students can insert courses for own request" on public.admit_card_request_courses;
create policy "Students can insert courses for own request"
on public.admit_card_request_courses
for insert
to authenticated
with check (
  exists (
    select 1
    from public.admit_card_requests r
    where r.id = admit_card_request_courses.request_id
    and r.student_auth_id = auth.uid()
  )
);

drop policy if exists "Admins can read all request courses" on public.admit_card_request_courses;
create policy "Admins can read all request courses"
on public.admit_card_request_courses
for select
to authenticated
using (
  public.is_admin()
);

drop policy if exists "Admins can manage request courses" on public.admit_card_request_courses;
create policy "Admins can manage request courses"
on public.admit_card_request_courses
for all
to authenticated
using (
  public.is_admin()
)
with check (
  public.is_admin()
);