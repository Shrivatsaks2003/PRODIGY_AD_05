import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';

class QRScannerScreen extends StatefulWidget {
  const QRScannerScreen({super.key});

  @override
  State<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  String scannedText = '';

  
Future<void> _launchURL(String url) async {
  // Ensure the URL has a valid scheme
  if (!url.startsWith('http://') && !url.startsWith('https://')) {
    url = 'https://$url';
  }

  final Uri uri = Uri.parse(url);

  try {
    // Attempt to launch the URL in an external application
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      print('Could not launch $url');
    }
  } catch (e) {
    print('Error launching URL: $e');
  }
}


  void _onQRDetect(BarcodeCapture barcodeCapture) {
    final barcodes = barcodeCapture.barcodes;
    if (barcodes.isNotEmpty) {
      final barcode = barcodes.first;
      final String? code = barcode.rawValue;

      if (code != null && code != scannedText) {
        setState(() {
          scannedText = code;
        });

        if (Uri.tryParse(code)?.hasScheme ?? false) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Open URL'),
              content: Text('Do you want to open this URL?\n$code'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _launchURL(code);
                  },
                  child: const Text('Yes'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('No'),
                ),
              ],
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Scanned: $code')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scan QR Code')),
      body: Column(
        children: [
          Expanded(
            child: MobileScanner(
              onDetect: _onQRDetect,
            ),
          ),
          if (scannedText.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text('Scanned: $scannedText'),
            ),
        ],
      ),
    );
  }
}
