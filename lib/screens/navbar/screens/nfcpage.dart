import 'package:flutter/material.dart';
import 'package:nfc_manager/nfc_manager.dart';
import '../navigation_drawer.dart' as custom; 

class NFCPage extends StatefulWidget {
  const NFCPage({super.key});

  @override
  _NFCPageState createState() => _NFCPageState();
}

class _NFCPageState extends State<NFCPage> {
  String status = 'Tap an NFC tag to read data.';
  List<String> nfcData = [];

  @override
  void initState() {
    super.initState();
    _checkNfcAvailability();
  }

  Future<void> _checkNfcAvailability() async {
    bool isAvailable = await NfcManager.instance.isAvailable();
    setState(() {
      status = isAvailable
          ? 'Ready to scan NFC tag.'
          : 'NFC is not available on this device.';
    });
  }

  Future<void> readNFC() async {
    try {
      setState(() => status = 'Ready to scan NFC tag...');
      await NfcManager.instance.startSession(
        onDiscovered: (NfcTag tag) async {
          final ndef = Ndef.from(tag);
          if (ndef == null || ndef.cachedMessage == null) {
            setState(() => status = 'No NDEF data found on this tag.');
            return;
          }

          final records = ndef.cachedMessage!.records;
          final payloads = records.map((record) {
            return String.fromCharCodes(record.payload);
          }).toList();

          setState(() {
            nfcData = payloads;
            status = 'NFC data read successfully.';
          });

          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('NFC Tag Data'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: nfcData.map((data) => Text(data)).toList(),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('OK'),
                ),
              ],
            ),
          );

          await NfcManager.instance.stopSession();
        },
      );
    } catch (e) {
      setState(() => status = 'Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('NFC Reader'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              status,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: readNFC,
              child: const Text('Read NFC'),
            ),
            const SizedBox(height: 16),
            if (nfcData.isNotEmpty)
              Column(
                children: [
                  const Text(
                    'Last Scanned NFC Data:',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  ...nfcData.map((data) => Text(data)),
                ],
              ),
          ],
        ),
      ),
      drawer: const custom.NavigationDrawer(),
    );
  }
}
