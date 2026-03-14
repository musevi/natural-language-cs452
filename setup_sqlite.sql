-- guitar teacher schema (SQLite-compatible)

PRAGMA foreign_keys = ON;

create table teacher (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL,
  email TEXT NOT NULL UNIQUE,
  phone TEXT
);

create table student (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL,
  email TEXT NOT NULL UNIQUE,
  phone TEXT,
  date_of_birth DATE,
  skill_level TEXT CHECK (skill_level IN ('beginner','intermediate','advanced')),
  enrolled_at DATE NOT NULL DEFAULT (date('now'))
);

create table lesson (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  teacher_id INTEGER NOT NULL,
  student_id INTEGER NOT NULL,
  scheduled_at DATETIME NOT NULL,
  duration_minutes INTEGER NOT NULL DEFAULT 60,
  status TEXT NOT NULL DEFAULT 'scheduled' CHECK (status IN ('scheduled','completed','cancelled','no-show')),
  notes TEXT,
  location TEXT NOT NULL DEFAULT 'in-person' CHECK (location IN ('in-person','online')),
  foreign key (teacher_id) references teacher(id),
  foreign key (student_id) references student(id)
);

create table material (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  lesson_id INTEGER NOT NULL,
  type TEXT NOT NULL CHECK (type IN ('song','technique','exercise','theory')),
  title TEXT NOT NULL,
  description TEXT,
  homework INTEGER NOT NULL DEFAULT 0,
  foreign key (lesson_id) references lesson(id)
);

create table package (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL,
  lesson_count INTEGER NOT NULL,
  price NUMERIC NOT NULL,
  validity_days INTEGER NOT NULL
);

create table student_package (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  student_id INTEGER NOT NULL,
  package_id INTEGER NOT NULL,
  lessons_remaining INTEGER NOT NULL,
  purchased_at DATE NOT NULL DEFAULT (date('now')),
  expires_at DATE NOT NULL,
  foreign key (student_id) references student(id),
  foreign key (package_id) references package(id)
);

create table invoice (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  student_id INTEGER NOT NULL,
  student_package_id INTEGER,
  amount NUMERIC NOT NULL,
  issued_at DATE NOT NULL DEFAULT (date('now')),
  due_at DATE NOT NULL,
  status TEXT NOT NULL DEFAULT 'unpaid' CHECK (status IN ('unpaid','paid','overdue')),
  foreign key (student_id) references student(id),
  foreign key (student_package_id) references student_package(id)
);

create table payment (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  invoice_id INTEGER NOT NULL,
  amount NUMERIC NOT NULL,
  method TEXT NOT NULL CHECK (method IN ('cash','card','venmo','bank transfer','other')),
  paid_at DATETIME NOT NULL DEFAULT (CURRENT_TIMESTAMP),
  foreign key (invoice_id) references invoice(id)
);
