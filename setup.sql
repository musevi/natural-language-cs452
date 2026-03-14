-- guitar teacher schema
 
create table teacher (
  id              int             not null auto_increment,
  name            varchar(100)    not null,
  email           varchar(150)    not null unique,
  phone           varchar(20),
  primary key (id)
);
 
create table student (
  id              int             not null auto_increment,
  name            varchar(100)    not null,
  email           varchar(150)    not null unique,
  phone           varchar(20),
  date_of_birth   date,
  skill_level     enum('beginner','intermediate','advanced'),
  enrolled_at     date            not null default (current_date),
  primary key (id)
);
 
create table lesson (
  id              int             not null auto_increment,
  teacher_id      int             not null,
  student_id      int             not null,
  scheduled_at    datetime        not null,
  duration_minutes int            not null default 60,
  status          enum('scheduled','completed','cancelled','no-show') not null default 'scheduled',
  notes           text,
  location        enum('in-person','online') not null default 'in-person',
  primary key (id),
  foreign key (teacher_id) references teacher(id),
  foreign key (student_id) references student(id)
);
 
create table material (
  id              int             not null auto_increment,
  lesson_id       int             not null,
  type            enum('song','technique','exercise','theory') not null,
  title           varchar(150)    not null,
  description     text,
  homework        tinyint(1)      not null default 0,
  primary key (id),
  foreign key (lesson_id) references lesson(id)
);
 
create table package (
  id              int             not null auto_increment,
  name            varchar(100)    not null,
  lesson_count    int             not null,
  price           decimal(8,2)    not null,
  validity_days   int             not null,
  primary key (id)
);
 
create table student_package (
  id                int           not null auto_increment,
  student_id        int           not null,
  package_id        int           not null,
  lessons_remaining int           not null,
  purchased_at      date          not null default (current_date),
  expires_at        date          not null,
  primary key (id),
  foreign key (student_id) references student(id),
  foreign key (package_id) references package(id)
);
 
create table invoice (
  id                  int         not null auto_increment,
  student_id          int         not null,
  student_package_id  int,
  amount              decimal(8,2) not null,
  issued_at           date        not null default (current_date),
  due_at              date        not null,
  status              enum('unpaid','paid','overdue') not null default 'unpaid',
  primary key (id),
  foreign key (student_id) references student(id),
  foreign key (student_package_id) references student_package(id)
);
 
create table payment (
  id              int             not null auto_increment,
  invoice_id      int             not null,
  amount          decimal(8,2)    not null,
  method          enum('cash','card','venmo','bank transfer','other') not null,
  paid_at         datetime        not null default current_timestamp,
  primary key (id),
  foreign key (invoice_id) references invoice(id)
);