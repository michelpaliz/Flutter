// lib/c-frontend/b-calendar-section/screens/profile/profile_view_screen.dart
import 'package:calendar_app_frontend/c-frontend/h-profile-section/edit/profile_edit_screen.dart';
import 'package:calendar_app_frontend/d-stateManagement/user/user_management.dart';
import 'package:calendar_app_frontend/e-drawer-style-menu/main_scaffold.dart';
import 'package:calendar_app_frontend/f-themes/palette/app_colors.dart';
import 'package:calendar_app_frontend/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'widgets/profile_bottom_actions.dart';
import 'widgets/profile_details_card.dart';
import 'widgets/profile_header_section.dart';

class ProfileViewScreen extends StatelessWidget {
  const ProfileViewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final user = context.watch<UserManagement>().user;
    if (user == null) {
      return MainScaffold(showAppBar: false, body: Center(child: Text(loc.noUserLoaded)));
    }

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final headerColor = isDark ? AppDarkColors.primary : AppColors.primary;

    final groupsCount = user.groupIds.length;
    final calendarsCount = user.sharedCalendars.length;
    final notificationsCount = user.notifications.length;

    void copyToClipboard(String text, String toast) {
      Clipboard.setData(ClipboardData(text: text));
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(toast)));
    }

    void comingSoon() =>
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(loc.comingSoon)));

    return MainScaffold(
      showAppBar: false,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
        slivers: [
          SliverToBoxAdapter(
            child: ProfileHeaderSection(
              title: loc.details,
              headerColor: headerColor,
              user: user,
              onEdit: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const ProfileEditScreen()), // EDIT screen
              ),
              onCopyEmail: () => copyToClipboard(user.email, loc.copiedToClipboard),
              groupsCount: groupsCount,
              calendarsCount: calendarsCount,
              notificationsCount: notificationsCount,
              onTapQuickGroups: comingSoon,
              onTapQuickCalendars: comingSoon,
              onTapQuickNotifications: comingSoon,
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 16)),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ProfileDetailsCard(
                email: user.email,
                username: '@${user.userName}',
                userId: user.id,
                groupsCount: groupsCount,
                calendarsCount: calendarsCount,
                notificationsCount: notificationsCount,
                onCopyEmail: () => copyToClipboard(user.email, loc.copiedToClipboard),
                onCopyId: () => copyToClipboard(user.id, loc.copiedToClipboard),
                onTapUsername: comingSoon,
                onTapTeams: comingSoon,
                onTapCalendars: comingSoon,
                onTapNotifications: comingSoon,
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 16)),

          // ✅ Fix: keep buttons above the home indicator and tappable
          SliverToBoxAdapter(
            child: SafeArea(
              top: false,
              minimum: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: ProfileBottomActions(
                addToContactsLabel: loc.addToContacts,
                shareLabel: loc.share,
                onAddToContacts: comingSoon,
                onShare: () {
                  final text = '${user.name} (@${user.userName}) • ${user.email}';
                  copyToClipboard(text, loc.copiedToClipboard);
                },
                primaryColor: isDark ? AppDarkColors.primary : AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
