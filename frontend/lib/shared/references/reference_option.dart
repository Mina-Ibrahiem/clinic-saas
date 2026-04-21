class ReferenceOption {
  const ReferenceOption({
    required this.id,
    required this.label,
    this.subtitle,
  });

  final int id;
  final String label;
  final String? subtitle;
}
