-- Dummy data for guitar teacher schema

insert into teacher (name, email, phone) values
  ('Ava Marshall', 'ava@guitarflow.com', '303-555-0101'),
  ('Luis Ortega', 'luis@stringschool.org', '303-555-0134'),
  ('Harper Reed', 'harper@openchords.net', '303-555-0199');

insert into student (name, email, phone, date_of_birth, skill_level, enrolled_at) values
  ('Maya Chen', 'maya.chen@example.com', '720-555-0023', '2008-06-17', 'intermediate', '2024-01-10'),
  ('Elijah Torres', 'elijah.torres@example.com', '720-555-0075', '2010-03-28', 'beginner', '2024-03-01'),
  ('Zoe Patel', 'zoe.patel@example.com', '720-555-0112', '2005-11-05', 'advanced', '2023-08-21'),
  ('Jonah Reed', 'jonah.reed@example.com', '720-555-0048', '2012-02-02', 'beginner', '2024-02-15'),
  ('Lena Park', 'lena.park@example.com', '720-555-0089', '2000-09-19', 'intermediate', '2023-05-16'),
  ('Kai Barnes', 'kai.barnes@example.com', '720-555-0060', '2011-12-30', 'beginner', '2024-04-03');

insert into package (name, lesson_count, price, validity_days) values
  ('Starter Pack', 4, 160.00, 45),
  ('Rhythm Builder', 8, 300.00, 90),
  ('Performance Ready', 12, 420.00, 120);

insert into student_package (student_id, package_id, lessons_remaining, purchased_at, expires_at) values
  (1, 2, 6, '2024-02-01', '2024-04-01'),
  (2, 1, 2, '2024-03-05', '2024-04-19'),
  (3, 3, 10, '2023-08-22', '2024-01-19'),
  (4, 1, 4, '2024-02-22', '2024-04-07'),
  (5, 2, 1, '2023-05-17', '2023-08-15');

insert into lesson (teacher_id, student_id, scheduled_at, duration_minutes, status, notes, location) values
  (1, 1, '2024-03-12 14:00:00', 60, 'completed', 'Focused on expanded chord shapes.', 'in-person'),
  (1, 2, '2024-03-15 15:30:00', 45, 'completed', 'Introduced open chords and rhythm strums.', 'online'),
  (2, 3, '2024-03-16 18:00:00', 60, 'scheduled', 'Working on solo phrasing for upcoming audition.', 'in-person'),
  (2, 4, '2024-03-18 10:00:00', 60, 'cancelled', 'Holiday reschedule; waiting for new date.', 'online'),
  (3, 5, '2024-03-19 16:30:00', 75, 'completed', 'Refreshed on fingerstyle patterns.', 'in-person'),
  (3, 6, '2024-03-20 14:45:00', 45, 'no-show', 'Student missed lesson; followed up by text.', 'online');

insert into material (lesson_id, type, title, description, homework) values
  (1, 'technique', 'Stretching Arpeggios', 'Arpeggio warm-up across the fretboard with metronome.', 1),
  (1, 'song', 'C major groove', 'Song example highlighting 6/8 feel.', 0),
  (2, 'exercise', 'Open chord mash-up', 'Switch between G, C, D, and Em while keeping tempo.', 1),
  (3, 'song', 'Minor pentatonic solo study', 'Call-and-response exercise with backing track.', 1),
  (5, 'theory', 'Modal interchange primer', 'Compare Dorian vs. Aeolian on the same progression.', 1);

insert into invoice (student_id, student_package_id, amount, issued_at, due_at, status) values
  (1, 1, 300.00, '2024-02-01', '2024-02-15', 'paid'),
  (2, 2, 160.00, '2024-03-05', '2024-03-19', 'paid'),
  (3, 3, 420.00, '2023-08-22', '2023-09-05', 'overdue'),
  (4, 4, 160.00, '2024-02-22', '2024-03-07', 'unpaid'),
  (5, 5, 300.00, '2023-05-17', '2023-06-01', 'paid');

insert into payment (invoice_id, amount, method, paid_at) values
  (1, 300.00, 'card', '2024-02-10 11:20:00'),
  (2, 160.00, 'venmo', '2024-03-08 09:45:00'),
  (5, 300.00, 'bank transfer', '2023-05-20 16:00:00');
