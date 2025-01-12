bool isImageFile(String path) {
  final extensions = ['jpg', 'jpeg', 'png', 'bmp', 'gif'];
  final ext = path.split('.').last.toLowerCase();
  return extensions.contains(ext);
}