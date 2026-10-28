// Web implementation using dart:html
// ignore_for_file: deprecated_member_use
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'dart:async';
import 'dart:typed_data';
import 'package:image/image.dart' as img;

class PickedImage {
  final Uint8List bytes;
  final String name;
  final String? path;

  PickedImage({
    required this.bytes,
    required this.name,
    this.path,
  });
}

Uint8List compressImageIfNeeded(Uint8List bytes) {
  if (bytes.lengthInBytes <= 450 * 1024) return bytes;
  try {
    final image = img.decodeImage(bytes);
    if (image == null) return bytes;
    img.Image resized = image;
    if (image.width > 1200 || image.height > 1200) {
      resized = img.copyResize(
        image,
        width: image.width > image.height ? 1200 : null,
        height: image.height >= image.width ? 1200 : null,
      );
    }
    final compressed = img.encodeJpg(resized, quality: 80);
    return Uint8List.fromList(compressed);
  } catch (e) {
    return bytes;
  }
}

/// Pick an image file from the browser
Future<PickedImage?> pickImageFromDevice() async {
  final completer = Completer<PickedImage?>();

  final input = html.FileUploadInputElement()
    ..accept = 'image/*'
    ..style.display = 'none';

  html.document.body?.children.add(input);

  input.onChange.listen((event) {
    final file = input.files?.first;
    if (file == null) {
      input.remove();
      if (!completer.isCompleted) completer.complete(null);
      return;
    }

    final reader = html.FileReader();
    reader.readAsArrayBuffer(file);
    reader.onLoadEnd.listen((e) {
      input.remove();
      final res = reader.result;
      Uint8List bytes;
      if (res is ByteBuffer) {
        bytes = res.asUint8List();
      } else if (res is Uint8List) {
        bytes = res;
      } else if (res is List<int>) {
        bytes = Uint8List.fromList(res);
      } else {
        bytes = Uint8List(0);
      }

      // Nén ảnh nếu dung lượng lớn để lưu Realtime Database mượt mà
      final optimizedBytes = compressImageIfNeeded(bytes);

      if (!completer.isCompleted) {
        completer.complete(PickedImage(bytes: optimizedBytes, name: file.name));
      }
    });
  });

  input.addEventListener('cancel', (_) {
    input.remove();
    if (!completer.isCompleted) completer.complete(null);
  });

  input.click();
  return completer.future;
}

/// Download bytes as file in web browser.
/// Uses DOM-attached anchor element and retains the Blob Object URL
/// long enough (30s) so modern Chrome/Edge download threads don't get canceled.
Future<String?> saveAndDownloadFile(Uint8List bytes, String fileName) async {
  try {
    final blob = html.Blob([bytes]);
    final url = html.Url.createObjectUrlFromBlob(blob);
    final anchor = html.AnchorElement(href: url)
      ..setAttribute('download', fileName)
      ..style.display = 'none';

    html.document.body?.children.add(anchor);
    anchor.click();
    anchor.remove();

    // Do NOT revoke immediately; give the browser 30 seconds to fetch and download
    Timer(const Duration(seconds: 30), () {
      html.Url.revokeObjectUrl(url);
    });

    return fileName;
  } catch (_) {
    return null;
  }
}

/// Open saved file stub on web
Future<void> openSavedFile(String filePath) async {
  // Not applicable on web
}
