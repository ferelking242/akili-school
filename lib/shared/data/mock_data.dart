/// Centralized mock data for the prototype — to be replaced by Supabase later.
import 'package:flutter/material.dart';

class MockStudent {
  final String id;
  final String name;
  final String classGroup;
  final double avg;
  final double attendance;
  final String guardian;
  const MockStudent({
    required this.id,
    required this.name,
    required this.classGroup,
    required this.avg,
    required this.attendance,
    required this.guardian,
  });
}

class MockGrade {
  final String subject;
  final String term;
  final double value;
  final String teacher;
  final DateTime date;
  const MockGrade({
    required this.subject,
    required this.term,
    required this.value,
    required this.teacher,
    required this.date,
  });
}

class MockCourse {
  final String code;
  final String name;
  final String teacher;
  final int hoursPerWeek;
  final IconData icon;
  final Color color;
  const MockCourse({
    required this.code,
    required this.name,
    required this.teacher,
    required this.hoursPerWeek,
    required this.icon,
    required this.color,
  });
}

class MockScheduleSlot {
  final String day;
  final String time;
  final String subject;
  final String room;
  final String teacher;
  const MockScheduleSlot({
    required this.day,
    required this.time,
    required this.subject,
    required this.room,
    required this.teacher,
  });
}

class MockInvoice {
  final String number;
  final String student;
  final String description;
  final double amount;
  final DateTime due;
  final InvoiceStatus status;
  const MockInvoice({
    required this.number,
    required this.student,
    required this.description,
    required this.amount,
    required this.due,
    required this.status,
  });
}

enum InvoiceStatus { paid, pending, overdue }

class MockMessage {
  final String from;
  final String preview;
  final String time;
  final bool unread;
  const MockMessage({
    required this.from,
    required this.preview,
    required this.time,
    required this.unread,
  });
}

class MockClass {
  final String name;
  final String level;
  final String teacher;
  final int students;
  const MockClass({
    required this.name,
    required this.level,
    required this.teacher,
    required this.students,
  });
}

class MockAttendanceEntry {
  final String student;
  final String classGroup;
  final String time;
  final AttendanceStatus status;
  const MockAttendanceEntry({
    required this.student,
    required this.classGroup,
    required this.time,
    required this.status,
  });
}

enum AttendanceStatus { present, late, absent }

class MockUser {
  final String name;
  final String email;
  final String role;
  final bool active;
  final String lastSeen;
  const MockUser({
    required this.name,
    required this.email,
    required this.role,
    required this.active,
    required this.lastSeen,
  });
}

class MockData {
  static final students = <MockStudent>[
    MockStudent(id: 'AKL-001', name: 'Ada Lovelace', classGroup: '5e A', avg: 16.2, attendance: .98, guardian: 'Augusta King'),
    MockStudent(id: 'AKL-002', name: 'Ben Kingsley', classGroup: '5e A', avg: 14.1, attendance: .92, guardian: 'David Kingsley'),
    MockStudent(id: 'AKL-003', name: 'Chloé Martin', classGroup: '5e B', avg: 13.5, attendance: .89, guardian: 'Sophie Martin'),
    MockStudent(id: 'AKL-004', name: 'Dieudonné Mbo', classGroup: '4e A', avg: 17.8, attendance: 1.0, guardian: 'Léa Mbo'),
    MockStudent(id: 'AKL-005', name: 'Eunice Otieno', classGroup: '4e A', avg: 15.0, attendance: .94, guardian: 'James Otieno'),
    MockStudent(id: 'AKL-006', name: 'Fatou Diallo', classGroup: '4e B', avg: 12.3, attendance: .81, guardian: 'Mariam Diallo'),
    MockStudent(id: 'AKL-007', name: 'Gabriel Ndiaye', classGroup: '3e A', avg: 14.6, attendance: .96, guardian: 'Aïda Ndiaye'),
    MockStudent(id: 'AKL-008', name: 'Hanae Bouzid', classGroup: '3e A', avg: 18.2, attendance: 1.0, guardian: 'Karim Bouzid'),
  ];

  static final courses = <MockCourse>[
    MockCourse(code: 'MAT', name: 'Mathematics', teacher: 'M. Dupont', hoursPerWeek: 5, icon: Icons.calculate_rounded, color: const Color(0xFF6D28D9)),
    MockCourse(code: 'PHY', name: 'Physics', teacher: 'Mme Lefèvre', hoursPerWeek: 4, icon: Icons.science_rounded, color: const Color(0xFF0EA5E9)),
    MockCourse(code: 'FRA', name: 'Français', teacher: 'M. Mbiya', hoursPerWeek: 4, icon: Icons.menu_book_rounded, color: const Color(0xFFEA580C)),
    MockCourse(code: 'ENG', name: 'English', teacher: 'Ms. Carter', hoursPerWeek: 3, icon: Icons.translate_rounded, color: const Color(0xFF16A34A)),
    MockCourse(code: 'HIS', name: 'History', teacher: 'M. Kabamba', hoursPerWeek: 2, icon: Icons.account_balance_rounded, color: const Color(0xFFDB2777)),
    MockCourse(code: 'BIO', name: 'Biology', teacher: 'Dr. Yao', hoursPerWeek: 3, icon: Icons.biotech_rounded, color: const Color(0xFF0891B2)),
    MockCourse(code: 'INF', name: 'Computer Science', teacher: 'M. Mukasa', hoursPerWeek: 2, icon: Icons.terminal_rounded, color: const Color(0xFF111827)),
  ];

  static final grades = <MockGrade>[
    MockGrade(subject: 'Mathematics', term: 'T2', value: 17.5, teacher: 'M. Dupont', date: DateTime(2026, 4, 12)),
    MockGrade(subject: 'Physics', term: 'T2', value: 14.0, teacher: 'Mme Lefèvre', date: DateTime(2026, 4, 9)),
    MockGrade(subject: 'Français', term: 'T2', value: 15.5, teacher: 'M. Mbiya', date: DateTime(2026, 4, 5)),
    MockGrade(subject: 'English', term: 'T2', value: 16.0, teacher: 'Ms. Carter', date: DateTime(2026, 3, 28)),
    MockGrade(subject: 'History', term: 'T2', value: 12.5, teacher: 'M. Kabamba', date: DateTime(2026, 3, 22)),
    MockGrade(subject: 'Biology', term: 'T2', value: 18.0, teacher: 'Dr. Yao', date: DateTime(2026, 3, 18)),
  ];

  static final schedule = <MockScheduleSlot>[
    MockScheduleSlot(day: 'Mon', time: '08:00–09:30', subject: 'Mathematics', room: 'B-204', teacher: 'M. Dupont'),
    MockScheduleSlot(day: 'Mon', time: '09:45–11:15', subject: 'English',     room: 'A-110', teacher: 'Ms. Carter'),
    MockScheduleSlot(day: 'Mon', time: '13:00–14:30', subject: 'Physics',     room: 'C-301', teacher: 'Mme Lefèvre'),
    MockScheduleSlot(day: 'Tue', time: '08:00–09:30', subject: 'Français',    room: 'A-205', teacher: 'M. Mbiya'),
    MockScheduleSlot(day: 'Tue', time: '09:45–11:15', subject: 'Biology',     room: 'C-105', teacher: 'Dr. Yao'),
    MockScheduleSlot(day: 'Wed', time: '08:00–09:30', subject: 'History',     room: 'B-101', teacher: 'M. Kabamba'),
    MockScheduleSlot(day: 'Wed', time: '13:00–14:30', subject: 'Mathematics', room: 'B-204', teacher: 'M. Dupont'),
    MockScheduleSlot(day: 'Thu', time: '09:45–11:15', subject: 'Computer Science', room: 'L-001', teacher: 'M. Mukasa'),
    MockScheduleSlot(day: 'Fri', time: '08:00–09:30', subject: 'Physics',     room: 'C-301', teacher: 'Mme Lefèvre'),
    MockScheduleSlot(day: 'Fri', time: '09:45–11:15', subject: 'Français',    room: 'A-205', teacher: 'M. Mbiya'),
  ];

  static final invoices = <MockInvoice>[
    MockInvoice(number: 'INV-26041', student: 'Ada Lovelace',    description: 'Tuition — April', amount: 320.0, due: DateTime(2026, 4, 30), status: InvoiceStatus.paid),
    MockInvoice(number: 'INV-26042', student: 'Ben Kingsley',    description: 'Tuition — April', amount: 320.0, due: DateTime(2026, 4, 30), status: InvoiceStatus.pending),
    MockInvoice(number: 'INV-26043', student: 'Chloé Martin',    description: 'Cantine — April', amount:  85.0, due: DateTime(2026, 4, 30), status: InvoiceStatus.overdue),
    MockInvoice(number: 'INV-26044', student: 'Dieudonné Mbo',   description: 'Tuition — April', amount: 320.0, due: DateTime(2026, 4, 30), status: InvoiceStatus.paid),
    MockInvoice(number: 'INV-26045', student: 'Eunice Otieno',   description: 'Bus — April',     amount:  60.0, due: DateTime(2026, 4, 30), status: InvoiceStatus.paid),
    MockInvoice(number: 'INV-26046', student: 'Fatou Diallo',    description: 'Tuition — April', amount: 320.0, due: DateTime(2026, 4, 30), status: InvoiceStatus.overdue),
    MockInvoice(number: 'INV-26047', student: 'Gabriel Ndiaye',  description: 'Tuition — April', amount: 320.0, due: DateTime(2026, 4, 30), status: InvoiceStatus.pending),
  ];

  static final messages = <MockMessage>[
    MockMessage(from: 'M. Dupont',     preview: 'The new schedule for May is now available.',  time: '09:14', unread: true),
    MockMessage(from: 'Finance Office', preview: 'Reminder: tuition due by April 30.',          time: '08:02', unread: true),
    MockMessage(from: 'Surveillance',   preview: 'Ben Kingsley arrived late this morning.',    time: 'Yesterday', unread: false),
    MockMessage(from: 'Dr. Yao',        preview: 'Field trip permission slips available.',     time: '2 days ago', unread: false),
  ];

  static final classes = <MockClass>[
    MockClass(name: '5e A',    level: 'Lower secondary', teacher: 'M. Dupont',  students: 28),
    MockClass(name: '5e B',    level: 'Lower secondary', teacher: 'Mme Lefèvre', students: 26),
    MockClass(name: '4e A',    level: 'Lower secondary', teacher: 'M. Mbiya',    students: 30),
    MockClass(name: '4e B',    level: 'Lower secondary', teacher: 'Ms. Carter',  students: 27),
    MockClass(name: '3e A',    level: 'Lower secondary', teacher: 'M. Kabamba',  students: 24),
    MockClass(name: '3e B',    level: 'Lower secondary', teacher: 'Dr. Yao',     students: 25),
  ];

  static final attendance = <MockAttendanceEntry>[
    MockAttendanceEntry(student: 'Ada Lovelace',    classGroup: '5e A', time: '07:48', status: AttendanceStatus.present),
    MockAttendanceEntry(student: 'Ben Kingsley',    classGroup: '5e A', time: '08:12', status: AttendanceStatus.late),
    MockAttendanceEntry(student: 'Chloé Martin',    classGroup: '5e B', time: '07:55', status: AttendanceStatus.present),
    MockAttendanceEntry(student: 'Dieudonné Mbo',   classGroup: '4e A', time: '07:39', status: AttendanceStatus.present),
    MockAttendanceEntry(student: 'Eunice Otieno',   classGroup: '4e A', time: '—',      status: AttendanceStatus.absent),
    MockAttendanceEntry(student: 'Fatou Diallo',    classGroup: '4e B', time: '07:50', status: AttendanceStatus.present),
    MockAttendanceEntry(student: 'Gabriel Ndiaye',  classGroup: '3e A', time: '08:25', status: AttendanceStatus.late),
    MockAttendanceEntry(student: 'Hanae Bouzid',    classGroup: '3e A', time: '07:43', status: AttendanceStatus.present),
  ];

  static final users = <MockUser>[
    MockUser(name: 'Sarah Mukasa',   email: 'sarah.m@scolaris.app',   role: 'admin',        active: true,  lastSeen: '2 min ago'),
    MockUser(name: 'M. Dupont',      email: 'dupont@scolaris.app',    role: 'teacher',      active: true,  lastSeen: '8 min ago'),
    MockUser(name: 'Mme Lefèvre',    email: 'lefevre@scolaris.app',   role: 'teacher',      active: true,  lastSeen: '15 min ago'),
    MockUser(name: 'Jean Tshibangu', email: 'jt@scolaris.app',        role: 'finance',      active: true,  lastSeen: '1 hour ago'),
    MockUser(name: 'Pierre Olongo',  email: 'olongo@scolaris.app',    role: 'surveillance', active: true,  lastSeen: '3 hours ago'),
    MockUser(name: 'Ada Lovelace',   email: 'ada.l@scolaris.app',     role: 'student',      active: true,  lastSeen: 'Yesterday'),
    MockUser(name: 'Ben Kingsley',   email: 'ben.k@scolaris.app',     role: 'student',      active: true,  lastSeen: 'Yesterday'),
    MockUser(name: 'Marc Diallo',    email: 'm.diallo@scolaris.app',  role: 'parent',       active: false, lastSeen: '5 days ago'),
  ];

  static double totalCollected() =>
      invoices.where((i) => i.status == InvoiceStatus.paid).fold(0.0, (a, b) => a + b.amount);
  static double totalPending() =>
      invoices.where((i) => i.status == InvoiceStatus.pending).fold(0.0, (a, b) => a + b.amount);
  static double totalOverdue() =>
      invoices.where((i) => i.status == InvoiceStatus.overdue).fold(0.0, (a, b) => a + b.amount);
}
