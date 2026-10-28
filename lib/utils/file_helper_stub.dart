import 'dart:io';
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

/// Pick an image file from the device (Native file dialog on Windows)
Future<PickedImage?> pickImageFromDevice() async {
  if (Platform.isWindows) {
    try {
      // Using PowerShell STA to open Windows native OpenFileDialog reliably
      const script = r'''
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
Add-Type -AssemblyName System.Windows.Forms
$dialog = New-Object System.Windows.Forms.OpenFileDialog
$dialog.Filter = "Image Files (*.jpg;*.jpeg;*.png;*.webp;*.bmp)|*.jpg;*.jpeg;*.png;*.webp;*.bmp|All Files (*.*)|*.*"
$dialog.Title = "Chọn ảnh minh chứng chiến dịch Mùa Hè Xanh"
$dialog.Multiselect = $false
if ($dialog.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
    Write-Output $dialog.FileName
}
''';
      final result = await Process.run(
        'powershell',
        ['-NoProfile', '-STA', '-Command', script],
        stdoutEncoding: const SystemEncoding(),
      );

      final selectedPath = result.stdout.toString().trim();
      if (selectedPath.isNotEmpty && File(selectedPath).existsSync()) {
        final file = File(selectedPath);
        final rawBytes = await file.readAsBytes();
        final bytes = compressImageIfNeeded(rawBytes);
        final name = selectedPath.split(RegExp(r'[\\/]')).last;
        return PickedImage(bytes: bytes, name: name, path: selectedPath);
      }
    } catch (_) {}
  }
  return null;
}

/// Save bytes to user's computer (Downloads directory on Windows)
/// Returns the full file path where the file was saved.
Future<String?> saveAndDownloadFile(Uint8List bytes, String fileName) async {
  try {
    String? targetDir;
    if (Platform.isWindows) {
      final userProfile = Platform.environment['USERPROFILE'];
      if (userProfile != null) {
        final downloads = '$userProfile\\Downloads';
        if (Directory(downloads).existsSync()) {
          targetDir = downloads;
        } else {
          targetDir = userProfile;
        }
      }
    }

    targetDir ??= Directory.current.path;

    // Ensure safe file name
    final safeName = fileName.replaceAll(RegExp(r'[\\/:*?"<>|]'), '_');
    final filePath = '$targetDir\\$safeName';
    final file = File(filePath);
    await file.writeAsBytes(bytes, flush: true);

    // On Windows, highlight the newly exported file in Windows Explorer
    if (Platform.isWindows) {
      try {
        await Process.run('explorer.exe', ['/select,', filePath]);
      } catch (_) {}
    }

    return filePath;
  } catch (e) {
    return null;
  }
}

/// Open a saved file using system default program
Future<void> openSavedFile(String filePath) async {
  if (Platform.isWindows && File(filePath).existsSync()) {
    try {
      await Process.run('cmd', ['/c', 'start', '""', filePath], runInShell: true);
    } catch (_) {}
  }
}
