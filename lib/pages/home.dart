import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share/share.dart';
import 'package:ins_scan/models/scans.dart';
import 'package:ins_scan/pages/help.dart';
import 'package:ins_scan/pages/scan.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MassQR'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.help_outline),
            tooltip: 'Help',
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => HelpPage(),
                  ));
            },
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          Expanded(
              child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Consumer<ScansModel>(
                    builder: (context, scans, child) {
                      return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(scans.scans.length == 0
                                ? 'No scans yet. Use the Scan button to start.'
                                : '${scans.scans.length} Scan${scans.scans.length > 1 ? 's' : ''}:'),
                            (scans.scans.length > 0
                                ? Expanded(
                                    child: ListView(
                                    children: scans.scans
                                        .map((e) => Container(
                                              padding: const EdgeInsets.fromLTRB(
                                                  0, 10, 0, 10),
                                              child: Text(e),
                                            ))
                                        .toList(),
                                    shrinkWrap: true,
                                  ))
                                : const Text('')),
                            Row(children: [
                              Expanded(
                                child: ElevatedButton(
                                    onPressed: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => ScanPage(),
                                          ));
                                    },
                                    child: const Text('Scan')),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: ElevatedButton(
                                    onPressed: scans.scans.length == 0
                                        ? null
                                        : () async {
                                            await exportData(scans.scans);
                                          },
                                    child: const Text('Export')),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: scans.scans.length == 0
                                      ? null
                                      : () {
                                          showDialog(
                                              context: context,
                                              builder: (context) => AlertDialog(
                                                    title:
                                                        const Text('Are you sure?'),
                                                    content: const Text(
                                                        'This will delete all scans.\n\nTo save them first, use the Export button and pick a destination.'),
                                                    actions: <Widget>[
                                                      TextButton(
                                                          onPressed: () {
                                                            Navigator.pop(
                                                                context);
                                                          },
                                                          child:
                                                              const Text('Cancel')),
                                                      TextButton(
                                                          onPressed: () {
                                                            scans.removeAll();
                                                            Navigator.pop(
                                                                context);
                                                            ScaffoldMessenger
                                                                    .of(context)
                                                                .showSnackBar(
                                                                    const SnackBar(
                                                                        content:
                                                                            Text('Deleted')));
                                                          },
                                                          style: TextButton.styleFrom(
                                                              foregroundColor: Theme.of(
                                                                      context)
                                                                  .colorScheme.error),
                                                          child: const Text('Delete'))
                                                    ],
                                                  ));
                                        },
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: Theme.of(context).colorScheme.error),
                                  child: const Text('Delete All'),
                                ),
                              )
                            ]),
                          ]);
                    },
                  ))),
        ],
      ),
    );
  }
}

String generateNowString() {
  String fillZeros(String string, int length) {
    while (string.length < length) {
      string = '0$string';
    }
    return string;
  }

  DateTime now = DateTime.now();
  return '${now.year}-${fillZeros(now.month.toString(), 2)}-${fillZeros(now.day.toString(), 2)}-${fillZeros(now.hour.toString(), 2)}-${fillZeros(now.minute.toString(), 2)}-${fillZeros(now.second.toString(), 2)}-${fillZeros(now.millisecond.toString(), 3)}';
}

Future<void> exportData(List<String> scans) async {
  String fileName = 'MassQR-Export-${generateNowString()}.txt';
  final String path = '${(await getTemporaryDirectory()).path}/$fileName';
  final File file = File(path);
  await file.writeAsString(scans.join('\n'), flush: true);
  await Share.shareFiles([path], text: 'MassQR Export');
}
