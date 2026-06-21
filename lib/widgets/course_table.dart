import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../models/course_model.dart';

class CourseTable extends StatelessWidget {
  final List<CourseModel> courses;
  final bool showRemoveButton;
  final void Function(CourseModel course)? onRemove;

  const CourseTable({
    super.key,
    required this.courses,
    this.showRemoveButton = false,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    if (courses.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.borderColor),
        ),
        child: const Text(
          'No courses available',
          style: TextStyle(
            color: AppColors.hintText,
            fontSize: 15,
          ),
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingRowColor: WidgetStateProperty.all(AppColors.lightBlue),
          dataRowMinHeight: 54,
          dataRowMaxHeight: 64,
          columnSpacing: 34,
          columns: [
            const DataColumn(
              label: Text(
                'Course Code',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
            const DataColumn(
              label: Text(
                'Course Title',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
            const DataColumn(
              label: Text(
                'Credit',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
            if (showRemoveButton)
              const DataColumn(
                label: Text(
                  'Action',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
          ],
          rows: courses.map((course) {
            return DataRow(
              cells: [
                DataCell(Text(course.courseCode)),
                DataCell(
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 360),
                    child: Text(
                      course.courseTitle,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                DataCell(Text(course.credit.toString())),
                if (showRemoveButton)
                  DataCell(
                    TextButton(
                      onPressed: onRemove == null
                          ? null
                          : () {
                              onRemove!(course);
                            },
                      child: const Text(
                        'Remove',
                        style: TextStyle(
                          color: AppColors.dangerRed,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}