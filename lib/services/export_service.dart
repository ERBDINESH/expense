import 'dart:io';
import 'dart:typed_data';
import 'package:csv/csv.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';
import '../models/expense_transaction.dart';

enum ExportFormat { pdf, csv }

class ExportService {
  static Future<void> exportData({
    required List<ExpenseTransaction> transactions,
    required int month,
    required int year,
    required ExportFormat format,
  }) async {
    final filtered = transactions.where((tx) => tx.date.month == month && tx.date.year == year).toList();
    filtered.sort((a, b) => b.date.compareTo(a.date));

    final monthName = DateFormat('MMMM').format(DateTime(year, month));
    final fileName = 'Moniqo_Report_${monthName}_$year';

    if (format == ExportFormat.pdf) {
      final pdfBytes = await _generatePdfBytes(filtered, monthName, year);
      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdfBytes,
        name: fileName,
      );
    } else {
      final csvPath = await _generateCsv(filtered, fileName);
      await Share.shareXFiles([XFile(csvPath)], text: 'Moniqo Expense Report');
    }
  }

  static Future<Uint8List> _generatePdfBytes(
    List<ExpenseTransaction> transactions,
    String monthName,
    int year,
  ) async {
    final pdf = pw.Document();
    final format = NumberFormat.simpleCurrency(locale: 'en_IN', decimalDigits: 2);

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (context) => [
          pw.Header(
            level: 0,
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text('Moniqo Expense Report', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
                pw.Text('$monthName $year'),
              ],
            ),
          ),
          pw.SizedBox(height: 20),
          pw.TableHelper.fromTextArray(
            headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            headers: ['Date', 'Category', 'Type', 'Amount', 'Notes'],
            data: transactions.map((tx) => [
              DateFormat('dd/MM/yyyy').format(tx.date),
              tx.categoryName,
              tx.type,
              format.format(tx.amount),
              tx.notes ?? '',
            ]).toList(),
          ),
          pw.SizedBox(height: 30),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.end,
            children: [
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  pw.Text('Total Income: ${format.format(transactions.where((t) => t.isCredit).fold(0.0, (sum, t) => sum + t.amount))}'),
                  pw.Text('Total Expense: ${format.format(transactions.where((t) => !t.isCredit).fold(0.0, (sum, t) => sum + t.amount))}'),
                  pw.Divider(),
                  pw.Text(
                    'Net: ${format.format(transactions.where((t) => t.isCredit).fold(0.0, (sum, t) => sum + t.amount) - transactions.where((t) => !t.isCredit).fold(0.0, (sum, t) => sum + t.amount))}',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );

    return await pdf.save();
  }

  static Future<String> _generateCsv(List<ExpenseTransaction> transactions, String fileName) async {
    List<List<dynamic>> rows = [
      ['Date', 'Category', 'Type', 'Amount', 'Notes'],
    ];

    for (var tx in transactions) {
      rows.add([
        DateFormat('dd/MM/yyyy').format(tx.date),
        tx.categoryName,
        tx.type,
        tx.amount,
        tx.notes ?? '',
      ]);
    }

    String csvData = const ListToCsvConverter().convert(rows);
    final output = await getTemporaryDirectory();
    final file = File('${output.path}/$fileName.csv');
    await file.writeAsString(csvData);
    return file.path;
  }
}
