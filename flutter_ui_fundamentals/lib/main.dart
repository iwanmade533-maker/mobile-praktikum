import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

Future<Map<String, dynamic>> loadStudentData() async {
  final jsonString = await rootBundle.loadString(
    'assets/data/student_data.json',
  );

  return jsonDecode(jsonString) as Map<String, dynamic>;
}

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Learning Dashboard',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
        ),
        useMaterial3: true,
      ),
      home: const DashboardPage(),
    );
  }
}

// Reusable Widget 1
class SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const SummaryCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Icon(
                icon,
                size: 30,
              ),
              const SizedBox(height: 8),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(title),
            ],
          ),
        ),
      ),
    );
  }
}

// Reusable Widget 2
class CourseCard extends StatelessWidget {
  final Map<String, dynamic> course;

  const CourseCard({
    super.key,
    required this.course,
  });

  @override
  Widget build(BuildContext context) {
    final status = course['status'] as String;

    final bool isDone = status == 'done';
    final bool isActive = status == 'active';

    final IconData statusIcon;

    if (isDone) {
      statusIcon = Icons.check_circle;
    } else if (isActive) {
      statusIcon = Icons.play_circle;
    } else {
      statusIcon = Icons.schedule;
    }

    final String statusText;

    if (isDone) {
      statusText = 'Selesai';
    } else if (isActive) {
      statusText = 'Aktif';
    } else {
      statusText = 'Rencana';
    }

    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 6,
      ),
      child: ListTile(
        leading: Icon(
          statusIcon,
          size: 32,
        ),
        title: Text(
          course['title'] as String,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          '${course['code']} • ${course['credits']} SKS',
        ),
        trailing: Text(
          statusText,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  late Future<Map<String, dynamic>> studentFuture;

  @override
  void initState() {
    super.initState();

    studentFuture = loadStudentData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Learning Dashboard'),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: studentFuture,
        builder: (context, snapshot) {
          // Loading state
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          // Error state
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Gagal memuat data:\n${snapshot.error}',
                textAlign: TextAlign.center,
              ),
            );
          }

          // Data berhasil
          final data = snapshot.data!;

          final student =
              data['student'] as Map<String, dynamic>;

          final courses =
              data['courses'] as List<dynamic>;

          // Menghitung summary
          final int totalCourses = courses.length;

          final int totalCredits = courses.fold(
            0,
            (sum, course) =>
                sum + (course['credits'] as int),
          );

          return SafeArea(
            child: Column(
              children: [
                // Profile
                Card(
                  margin: const EdgeInsets.all(16),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        const CircleAvatar(
                          radius: 40,
                          backgroundImage: AssetImage(
                            'assets/images/profile.jpg',
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Text(
                                student['name'] as String,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                student['nim'] as String,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Semester ${student['semester']}',
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Summary
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                  ),
                  child: Row(
                    children: [
                      SummaryCard(
                        title: 'Mata Kuliah',
                        value: '$totalCourses',
                        icon: Icons.menu_book,
                      ),
                      const SizedBox(width: 12),
                      SummaryCard(
                        title: 'Total SKS',
                        value: '$totalCredits',
                        icon: Icons.school,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                const Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16,
                  ),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Daftar Mata Kuliah',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 6),

                // =================================================
                // TAHAP 15 - KASUS A
                // Perbaikan RenderFlex Overflow menggunakan Expanded
                // =================================================
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '${student['nim']} - ${student['name']} - tugas flutter fundamental',
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 8),

                // List
                Expanded(
                  child: ListView.builder(
                    itemCount: courses.length,
                    itemBuilder: (context, index) {
                      final course =
                          courses[index]
                              as Map<String, dynamic>;

                      return CourseCard(
                        course: course,
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}