import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../constants/app_assets.dart';
import '../models/admit_card_request_model.dart';
import '../models/course_model.dart';
import '../models/student_model.dart';


class PdfService {
  Future<void> generateAndDownloadAdmitCard({
    required StudentModel student,
    required AdmitCardRequestModel request,
    required List<CourseModel> courses,
  }) async {
    if (request.status != 'approved') {
      throw Exception('Admit card is not approved yet.');
    }

    final pdfBytes = await _buildAdmitCardPdf(
      student: student,
      request: request,
      courses: courses,
    );

    await Printing.sharePdf(
      bytes: pdfBytes,
      filename: 'admit_card_${student.studentId}_semester_${student.semester}.pdf',
    );
  }

  Future<Uint8List> _buildAdmitCardPdf({
    required StudentModel student,
    required AdmitCardRequestModel request,
    required List<CourseModel> courses,
  }) async {
    final pdf = pw.Document();

    final logoBytes = await rootBundle.load(AppAssets.luLogo);
    final logoImage = pw.MemoryImage(logoBytes.buffer.asUint8List());

    final qrValue = 'digitaladmitcard://verify/${request.id}';

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(24),
        build: (context) {
          return pw.Container(
            padding: const pw.EdgeInsets.all(18),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(
                color: PdfColors.black,
                width: 1,
              ),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                _buildPdfHeader(logoImage),
                pw.SizedBox(height: 24),
                _buildStudentInfoSection(
                  student: student,
                  request: request,
                  qrValue: qrValue,
                ),
                pw.SizedBox(height: 34),
                _buildCourseTable(courses),
                pw.Spacer(),
                _buildFooter(),
              ],
            ),
          );
        },
      ),
    );

    return pdf.save();
  }

  pw.Widget _buildPdfHeader(pw.MemoryImage logoImage) {
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.center,
      children: [
        pw.Image(
          logoImage,
          width: 80,
          height: 80,
        ),
        pw.SizedBox(width: 18),
        pw.Expanded(
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: [
              pw.Text(
                'LEADING UNIVERSITY',
                textAlign: pw.TextAlign.center,
                style: pw.TextStyle(
                  fontSize: 26,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 10),
              pw.Text(
                'ADMIT CARD',
                textAlign: pw.TextAlign.center,
                style: pw.TextStyle(
                  fontSize: 20,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 4),
              pw.Container(
                width: 180,
                height: 1,
                color: PdfColors.black,
              ),
            ],
          ),
        ),
        pw.SizedBox(width: 98),
      ],
    );
  }

  pw.Widget _buildStudentInfoSection({
    required StudentModel student,
    required AdmitCardRequestModel request,
    required String qrValue,
  }) {
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Expanded(
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              _infoRow('Student ID', student.studentId),
              pw.SizedBox(height: 10),
              _infoRow('Student Name', student.name),
              pw.SizedBox(height: 10),
              _infoRow('Batch', student.batch),
              pw.SizedBox(height: 10),
              _infoRow('Semester', student.semester.toString()),
            ],
          ),
        ),
        pw.SizedBox(width: 30),
        pw.Column(
          children: [
            pw.Container(
              padding: const pw.EdgeInsets.all(6),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.black),
              ),
              child: pw.BarcodeWidget(
                barcode: pw.Barcode.qrCode(),
                data: qrValue,
                width: 100,
                height: 100,
              ),
            ),
            pw.SizedBox(height: 8),
            pw.Text(
              'Scan to Verify',
              style: const pw.TextStyle(
                fontSize: 11,
              ),
            ),
          ],
        ),
      ],
    );
  }

  pw.Widget _infoRow(String label, String value) {
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.SizedBox(
          width: 105,
          child: pw.Text(
            '$label:',
            style: pw.TextStyle(
              fontSize: 13,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
        ),
        pw.Expanded(
          child: pw.Text(
            value,
            style: const pw.TextStyle(
              fontSize: 13,
            ),
          ),
        ),
      ],
    );
  }

  pw.Widget _buildCourseTable(List<CourseModel> courses) {
    return pw.Table(
      border: pw.TableBorder.all(
        color: PdfColors.grey700,
        width: 0.7,
      ),
      columnWidths: const {
        0: pw.FlexColumnWidth(1.4),
        1: pw.FlexColumnWidth(4.8),
        2: pw.FlexColumnWidth(1.2),
      },
      children: [
        pw.TableRow(
          decoration: const pw.BoxDecoration(
            color: PdfColors.grey300,
          ),
          children: [
            _tableHeaderCell('Course Code'),
            _tableHeaderCell('Course Title'),
            _tableHeaderCell('Credit'),
          ],
        ),
        ...courses.map((course) {
          return pw.TableRow(
            children: [
              _tableBodyCell(course.courseCode),
              _tableBodyCell(course.courseTitle),
              _tableBodyCell(course.credit.toString()),
            ],
          );
        }),
      ],
    );
  }

  pw.Widget _tableHeaderCell(String text) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 9,
      ),
      child: pw.Text(
        text,
        textAlign: pw.TextAlign.center,
        style: pw.TextStyle(
          fontSize: 11,
          fontWeight: pw.FontWeight.bold,
        ),
      ),
    );
  }

  pw.Widget _tableBodyCell(String text) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 8,
      ),
      child: pw.Text(
        text,
        textAlign: pw.TextAlign.center,
        style: const pw.TextStyle(
          fontSize: 10.5,
        ),
      ),
    );
  }

  pw.Widget _buildFooter() {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.center,
      children: [
        pw.Center(
          child: pw.Container(
            width: 260,
            padding: const pw.EdgeInsets.all(10),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.grey700),
            ),
            child: pw.Text(
              'This admit card is digitally generated\nand can be verified using the QR code.',
              textAlign: pw.TextAlign.center,
              style: const pw.TextStyle(
                fontSize: 10,
              ),
            ),
          ),
        ),
        pw.SizedBox(height: 18),
        pw.Text(
          'N.B. Students are advised to preserve the Admit Card for future use and carry it during the examination.',
          textAlign: pw.TextAlign.center,
          style: const pw.TextStyle(
            fontSize: 10,
          ),
        ),
      ],
    );
  }
}