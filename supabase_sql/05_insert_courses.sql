insert into public.courses (
  semester,
  course_code,
  course_title,
  credit
)
values
  (1, 'CSE-111', 'Structured Programming', 3.0),
  (1, 'CSE-112', 'Structured Programming Lab', 1.5),
  (1, 'MAT-111', 'Differential and Integral Calculus', 3.0),

  (2, 'CSE-121', 'Object Oriented Programming', 3.0),
  (2, 'CSE-122', 'Object Oriented Programming Lab', 1.5),
  (2, 'MAT-121', 'Coordinate Geometry and Vector Analysis', 3.0),

  (3, 'CSE-211', 'Data Structure', 3.0),
  (3, 'CSE-212', 'Data Structure Lab', 1.5),
  (3, 'CSE-213', 'Digital Logic Design', 3.0),

  (4, 'CSE-221', 'Algorithm Design and Analysis', 3.0),
  (4, 'CSE-222', 'Algorithm Design and Analysis Lab', 1.5),
  (4, 'CSE-223', 'Database Management System', 3.0),

  (5, 'CSE-311', 'Operating System', 3.0),
  (5, 'CSE-312', 'Operating System Lab', 1.5),
  (5, 'CSE-313', 'Computer Architecture', 3.0)
on conflict (semester, course_code) do nothing;