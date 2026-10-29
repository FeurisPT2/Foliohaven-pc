import 'package:flutter/material.dart';
import 'package:foliohaven_flutter/domain/models/toc_item.dart';
import 'package:foliohaven_flutter/ui/core/constants/app_colors.dart';

class TocDrawer extends StatelessWidget {
  final List<TocItem> tocItems;
  final ValueChanged<int> onSelectPage;

  const TocDrawer({
    super.key,
    required this.tocItems,
    required this.onSelectPage,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppColors.sidebarBg,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  const Icon(Icons.list_alt, color: AppColors.primary, size: 20),
                  const SizedBox(width: 8),
                  const Text(
                    'Table of Contents',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close, size: 18, color: AppColors.textSecondary),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            const Divider(color: Color(0xFF292524), height: 1),
            Expanded(
              child: tocItems.isEmpty
                  ? const Center(
                      child: Text(
                        'No table of contents available.',
                        style: TextStyle(color: AppColors.textMuted, fontSize: 13),
                      ),
                    )
                  : ListView.builder(
                      itemCount: tocItems.length,
                      itemBuilder: (context, index) {
                        final item = tocItems[index];
                        final paddingLeft = 16.0 + (item.level * 16.0);

                        return ListTile(
                          contentPadding: EdgeInsets.only(left: paddingLeft, right: 16),
                          dense: true,
                          title: Text(
                            item.title,
                            style: TextStyle(
                              color: item.level == 0 ? AppColors.textPrimary : AppColors.textSecondary,
                              fontWeight: item.level == 0 ? FontWeight.w600 : FontWeight.w400,
                              fontSize: item.level == 0 ? 13 : 12,
                            ),
                          ),
                          trailing: Text(
                            'p. ${item.pageIndex + 1}',
                            style: const TextStyle(color: AppColors.textMuted, fontSize: 11),
                          ),
                          onTap: () {
                            Navigator.pop(context);
                            onSelectPage(item.pageIndex + 1);
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
