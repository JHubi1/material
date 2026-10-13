import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';
import 'package:url_launcher/url_launcher.dart';

final class QR {
  final QrCode _code;
  final String data;
  PrettyQrDecoration _decoration(BuildContext context) => PrettyQrDecoration(
    shape: PrettyQrSmoothSymbol(color: ColorScheme.of(context).primary),
  );

  QR(this.data)
    : _code = QrCode.fromData(
        data: data,
        errorCorrectLevel: QrErrorCorrectLevel.M,
      );

  Widget toWidget({Key? key, bool quietZone = true, bool clickable = true}) {
    final dataIsUrl =
        (Uri.tryParse(data)?.hasAbsolutePath ?? false) &&
        data.startsWith("http");
    return Builder(
      builder: (context) => GestureDetector(
        onLongPress: clickable
            ? () async {
                Feedback.forLongPress(context);
                if (dataIsUrl && await canLaunchUrl(Uri.parse(data))) {
                  await launchUrl(Uri.parse(data));
                } else {
                  await Clipboard.setData(ClipboardData(text: data));
                  if (context.mounted) {
                    ScaffoldMessenger.of(context)
                      ..clearSnackBars()
                      ..showSnackBar(
                        const SnackBar(content: Text("Copied to clipboard")),
                      );
                  }
                }
              }
            : null,
        child: PrettyQrView(
          key: key,
          qrImage: QrImage(_code),
          decoration: _decoration(context).copyWith(
            quietZone: quietZone
                ? PrettyQrQuietZone.standard
                : PrettyQrQuietZone.zero,
          ),
        ),
      ),
    );
  }

  Future<ImageProvider> toImage(BuildContext context) async => MemoryImage(
    (await QrImage(_code).toImageAsBytes(
      size: 512,
      decoration: _decoration(context),
    ))!.buffer.asUint8List(),
  );
}
