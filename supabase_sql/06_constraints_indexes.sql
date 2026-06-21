-- Allow public users to verify approved admit card requests only
drop policy if exists "Public can verify approved admit card requests" 
on public.admit_card_requests;

create policy "Public can verify approved admit card requests"
on public.admit_card_requests
for select
to anon
using (
  status = 'approved'
);

-- Allow public users to read courses only for approved admit card requests
drop policy if exists "Public can verify approved request courses"
on public.admit_card_request_courses;

create policy "Public can verify approved request courses"
on public.admit_card_request_courses
for select
to anon
using (
  exists (
    select 1
    from public.admit_card_requests r
    where r.id = admit_card_request_courses.request_id
    and r.status = 'approved'
  )
);