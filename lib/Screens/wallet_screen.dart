import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:managment/data/model/add_date.dart'; // Ensure this path is correct
import 'package:intl/intl.dart';
import 'dart:math';

class WalletScreen extends StatefulWidget {
  const WalletScreen({Key? key}) : super(key: key);

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  final Box<Add_data> box = Hive.box<Add_data>('data');
  final Random _random = Random();

  String _generateRandomTxId() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    return 'TX-' +
        String.fromCharCodes(Iterable.generate(
            8, (_) => chars.codeUnitAt(_random.nextInt(chars.length))));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.primaryColor;
    final textTheme = theme.textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text('Transaction History',
            style: TextStyle(
                color: theme.appBarTheme.foregroundColor ??
                    (ThemeData.estimateBrightnessForColor(primaryColor) ==
                            Brightness.dark
                        ? Colors.white
                        : Colors.black))),
        backgroundColor: primaryColor,
        elevation: 0.5,
      ),
      body: ValueListenableBuilder(
        valueListenable: box.listenable(),
        builder: (context, Box<Add_data> historyBox, _) {
          var transactions = historyBox.values.toList();
          transactions.sort((a, b) => b.datetime.compareTo(a.datetime));

          if (transactions.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.receipt_long_outlined,
                      size: 70, color: Colors.grey.shade400),
                  const SizedBox(height: 20),
                  Text(
                    'No transactions recorded yet.',
                    style: textTheme.titleMedium
                        ?.copyWith(color: Colors.grey.shade600),
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16.0),
            itemCount: transactions.length,
            itemBuilder: (context, index) {
              Add_data history = transactions[index];
              return _buildTransactionItem(history, theme);
            },
            separatorBuilder: (context, index) => Divider(
              height: 1,
              thickness: 0.5,
              indent: 16,
              endIndent: 16,
            ),
          );
        },
      ),
    );
  }

  Widget _buildTransactionItem(Add_data history, ThemeData theme) {
    String formattedDateTime =
        DateFormat('MMM dd, yyyy  •  hh:mm a').format(history.datetime);
    String randomTxId = _generateRandomTxId();
    bool isIncome = history.IN == 'Income';

    return Card(
      elevation: 0.8,
      margin: const EdgeInsets.symmetric(vertical: 7.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: isIncome ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10.0),
            child: Padding(
              padding: const EdgeInsets.all(4.0), // Padding for the image inside the container
              child: Image.asset(
                'images/${history.name}.png',
                 // Ensure these images exist and paths are correct and images are in `assets/images/` and declared in pubspec.yaml
                errorBuilder: (context, error, stackTrace) {
                  return Icon(
                    isIncome ? Icons.download_rounded : Icons.upload_rounded,
                    color: isIncome ? Colors.green.shade600 : Colors.red.shade600,
                    size: 26);
                },
              ),
            ),
          ),
        ),
        title: Text(
          history.name,
          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 5),
            Text(
              randomTxId, // Display random transaction ID
              style: theme.textTheme.bodySmall?.copyWith(
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              formattedDateTime,
              style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey.shade600),
            ),
          ],
        ),
        trailing: Text(
          '${isIncome ? '+' : '-'} \$${(double.tryParse(history.amount) ?? 0.0).toStringAsFixed(2)}',
          style: theme.textTheme.titleSmall?.copyWith( // Adjusted font size
            fontWeight: FontWeight.bold,
            color: isIncome ? Colors.green.shade700 : Colors.red.shade700,
          ),
        ),
        onTap: () {
          // TODO: Implement navigation to transaction detail or edit screen
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text('Tapped on ${history.name}'),
              duration: const Duration(seconds: 1)));
        },
      ),
    );
  }
}