class TocItem {
  final String title;
  final int pageIndex;
  final int level;

  const TocItem({
    required this.title,
    required this.pageIndex,
    this.level = 0,
  });
}
