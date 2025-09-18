// lib/c-frontend/b-calendar-section/screens/profile/profile_view_screen.dart
import 'package:calendar_app_frontend/d-stateManagement/user/user_management.dart';
import 'package:calendar_app_frontend/e-drawer-style-menu/main_scaffold.dart';
import 'package:calendar_app_frontend/f-themes/palette/app_colors.dart';
import 'package:calendar_app_frontend/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'widgets/profile_details_card.dart';
import 'widgets/profile_header_section.dart';

class ProfileViewScreen extends StatelessWidget {
  const ProfileViewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final user = context.watch<UserManagement>().user;
    if (user == null) {
      return MainScaffold(
          showAppBar: false, body: Center(child: Text(loc.noUserLoaded)));
    }

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final headerColor = isDark ? AppDarkColors.primary : AppColors.primary;

    final groupsCount = user.groupIds.length;
    final calendarsCount = user.sharedCalendars.length;
    final notificationsCount = user.notifications.length;

    void copyToClipboard(String text, String toast) {
      Clipboard.setData(ClipboardData(text: text));
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(toast)));
    }

    void comingSoon() => ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(loc.comingSoon)));

    return MainScaffold(
      showAppBar: false,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics()),
        slivers: [
          // Header (no edit icon anymore; edit comes from contextual FAB)
          SliverToBoxAdapter(
            child: ProfileHeaderSection(
              // title: loc.details,
              headerColor: headerColor,
              user: user,
              onCopyEmail: () =>
                  copyToClipboard(user.email, loc.copiedToClipboard),
              groupsCount: groupsCount,
              calendarsCount: calendarsCount,
              notificationsCount: notificationsCount,
              onTapQuickGroups: comingSoon,
              onTapQuickCalendars: comingSoon,
              onTapQuickNotifications: comingSoon,
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 16)),

          // Details card
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
                onCopyEmail: () =>
                    copyToClipboard(user.email, loc.copiedToClipboard),
                onCopyId: () => copyToClipboard(user.id, loc.copiedToClipboard),
                onTapUsername: comingSoon,
                onTapTeams: comingSoon,
                onTapCalendars: comingSoon,
                onTapNotifications: comingSoon,
              ),
            ),
          ),

          // Optional small bottom spacer so the last tile isn't tight to the bottom
          const SliverToBoxAdapter(child: SizedBox(height: 16)),
          const SliverToBoxAdapter(
            child: SafeArea(top: false, child: SizedBox(height: 8)),
          ),
        ],
      ),
    );
  }
}
