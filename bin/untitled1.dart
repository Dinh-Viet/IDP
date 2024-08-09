import 'dart:convert';
import 'dart:io';

class Student {
  String id;
  String name;
  Map<String, int> subjects;

  Student({required this.id, required this.name, required this.subjects});

  factory Student.fromJson(Map<String, dynamic> json) {
    return Student(
      id: json['id'],
      name: json['name'],
      subjects: Map<String, int>.from(json['subjects']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'subjects': subjects,
    };
  }
}

void main() {
  List<Student> students = loadStudents();

  while (true) {
    print('\nChương trình Quản lý Sinh viên');
    print('1. Hiển thị toàn bộ sinh viên');
    print('2. Thêm sinh viên');
    print('3. Sửa thông tin sinh viên');
    print('4. Tìm kiếm sinh viên theo Tên hoặc ID');
    print('5. Hiển thị sinh viên có điểm thi môn cao nhất');
    print('6. Thoát');

    stdout.write('Nhập lựa chọn của bạn: ');
    String? choice = stdin.readLineSync();

    switch (choice) {
      case '1':
        displayAllStudents(students);
        break;
      case '2':
        addStudent(students);
        break;
      case '3':
        editStudent(students);
        break;
      case '4':
        searchStudent(students);
        break;
      case '5':
        highestScoreInSubject(students);
        break;
      case '6':
        saveStudents(students);
        exit(0);
      default:
        print('Lựa chọn không hợp lệ. Vui lòng thử lại.');
    }
  }
}

List<Student> loadStudents() {
  try {
    final file = File('Student.json');
    final data = jsonDecode(file.readAsStringSync()) as List;
    return data.map((json) => Student.fromJson(json)).toList();
  } catch (e) {
    return [];
  }
}

void saveStudents(List<Student> students) {
  final file = File('Student.json');
  final data = students.map((student) => student.toJson()).toList();
  file.writeAsStringSync(jsonEncode(data), flush: true);
}

void displayAllStudents(List<Student> students) {
  if (students.isEmpty) {
    print('Không có sinh viên nào.');
    return;
  }

  for (var student in students) {
    print('ID: ${student.id}, Tên: ${student.name}');
    print('Danh sách môn học và điểm thi:');
    student.subjects.forEach((subject, score) {
      print('  Môn: $subject, Điểm: $score');
    });
    print('');
  }
}

void addStudent(List<Student> students) {
  stdout.write('Nhập ID: ');
  String id = stdin.readLineSync()!;

  stdout.write('Nhập tên: ');
  String name = stdin.readLineSync()!;

  Map<String, int> subjects = {};
  while (true) {
    stdout.write('Nhập tên môn học (hoặc \'done\' để kết thúc): ');
    String subject = stdin.readLineSync()!;
    if (subject.toLowerCase() == 'done') break;

    stdout.write('Nhập điểm cho môn $subject: ');
    int score = int.parse(stdin.readLineSync()!);
    subjects[subject] = score;
  }

  students.add(Student(id: id, name: name, subjects: subjects));
  print('Thêm sinh viên thành công.');
}

void editStudent(List<Student> students) {
  stdout.write('Nhập ID của sinh viên cần sửa: ');
  String id = stdin.readLineSync()!;

  Student? student = students.firstWhere((s) => s.id == id, orElse: () => Student(id: '', name: '', subjects: {}));
  if (student.id.isEmpty) {
    print('Không tìm thấy sinh viên.');
    return;
  }

  stdout.write('Nhập tên mới (hiện tại: ${student.name}): ');
  String name = stdin.readLineSync()!;
  student.name = name.isNotEmpty ? name : student.name;

  while (true) {
    stdout.write('Nhập \'add\', \'edit\', \'delete\' môn học hoặc \'done\' để kết thúc: ');
    String action = stdin.readLineSync()!.toLowerCase();
    if (action == 'done') break;

    stdout.write('Nhập tên môn học: ');
    String subject = stdin.readLineSync()!;

    if (action == 'add') {
      stdout.write('Nhập điểm cho môn $subject: ');
      int score = int.parse(stdin.readLineSync()!);
      student.subjects[subject] = score;
    } else if (action == 'edit') {
      if (student.subjects.containsKey(subject)) {
        stdout.write('Nhập điểm mới cho môn $subject (hiện tại: ${student.subjects[subject]}): ');
        int score = int.parse(stdin.readLineSync()!);
        student.subjects[subject] = score;
      } else {
        print('Môn $subject không tồn tại.');
      }
    } else if (action == 'delete') {
      if (student.subjects.containsKey(subject)) {
        student.subjects.remove(subject);
      } else {
        print('Môn $subject không tồn tại.');
      }
    }
  }
  print('Cập nhật thông tin sinh viên thành công.');
}

void searchStudent(List<Student> students) {
  stdout.write('Nhập tên hoặc ID sinh viên: ');
  String query = stdin.readLineSync()!;

  Student? student = students.firstWhere(
        (s) => s.name.toLowerCase() == query.toLowerCase() || s.id == query,
    orElse: () => Student(id: '', name: '', subjects: {}),
  );
  if (student.id.isNotEmpty) {
    print('ID: ${student.id}, Tên: ${student.name}');
    print('Danh sách môn học và điểm thi:');
    student.subjects.forEach((subject, score) {
      print('  Môn: $subject, Điểm: $score');
    });
  } else {
    print('Không tìm thấy sinh viên.');
  }
}

void highestScoreInSubject(List<Student> students) {
  stdout.write('Nhập tên môn học: ');
  String subject = stdin.readLineSync()!;

  List<Student> highestScoreStudents = [];
  int highestScore = -1;

  for (var student in students) {
    if (student.subjects.containsKey(subject)) {
      int score = student.subjects[subject]!;
      if (score > highestScore) {
        highestScore = score;
        highestScoreStudents = [student];
      } else if (score == highestScore) {
        highestScoreStudents.add(student);
      }
    }
  }

  if (highestScoreStudents.isNotEmpty) {
    print('Danh sách sinh viên có điểm cao nhất môn $subject:');
    for (var student in highestScoreStudents) {
      print('ID: ${student.id}, Tên: ${student.name}, Điểm: $highestScore');
    }
  } else {
    print('Không tìm thấy sinh viên học môn $subject hoặc không có dữ liệu điểm cho môn này.');
  }
}
