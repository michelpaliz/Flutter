// home_page.dart
import 'package:flutter/material.dart';
import 'package:hexora/a-models/user_model/user.dart';
import 'package:hexora/b-backend/group_mng_flow/group/domain/group_domain.dart';
// ❌ removed: group_view_model import
import 'package:hexora/b-backend/auth_user/auth/auth_database/auth_service.dart';
import 'package:hexora/b-backend/auth_user/user/domain/user_domain.dart';
import 'package:hexora/b-backend/notification/domain/socket_notification_listener.dart';
import 'package:hexora/c-frontend/c-group-calendar-section/screens/group/show-groups/group_screen/group_section.dart';
import 'package:hexora/c-frontend/c-group-calendar-section/screens/group/show-groups/motivational_phrase/motivation_banner.dart';
import 'package:hexora/c-frontend/routes/appRoutes.dart';
import 'package:hexora/c-frontend/utils/user_avatar.dart';
import 'package:hexora/e-drawer-style-menu/main_scaffold.dart';
import 'package:hexora/f-themes/themes/theme_colors.dart';
import 'package:hexora/l10n/app_localizations.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  User? _lastUser;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final user = context.watch<AuthService>().currentUser;

    if (user != null && user != _lastUser) {
      _lastUser = user;

      WidgetsBinding.instance.addPostFrameCallback((_) async {
        final userDomain = context.read<UserDomain>();
        final groupDomain = context.read<GroupDomain>();

        // seed domains with the new user
        userDomain.setCurrentUser(user);
        groupDomain.setCurrentUser(user);

        // sockets for notifications
        initializeNotificationSocket(user.id);

        // 🔄 refresh the repo-backed groups stream for this user
        await groupDomain.refreshGroupsForCurrentUser(userDomain);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final user = context.watch<AuthService>().currentUser;

    if (user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return MainScaffold(
      title: '',
      titleWidget: _AppBarUserTitle(user: user),
      actions: [
        IconButton(
          icon: const Icon(Icons.settings_outlined),
          tooltip: loc.settings,
          onPressed: () => Navigator.pushNamed(context, AppRoutes.settings),
        ),
      ],
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: _GreetingCard(user: user)),
          const SliverToBoxAdapter(child: SizedBox(height: 8)),
          SliverToBoxAdapter(
              child: _SectionHeader(title: loc.motivationSectionTitle)),
          const SliverToBoxAdapter(child: SizedBox(height: 8)),
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: MotivationBanner(dailyRotate: true),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 24)),
          SliverToBoxAdapter(
              child: _SectionHeader(title: loc.groupSectionTitle)),
          const SliverToBoxAdapter(child: SizedBox(height: 8)),
          const SliverToBoxAdapter(child: _ChangeViewRow()),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(top: 12, bottom: 24),
              child: GroupListSection(),
            ),
          ),
        ],
      ),
    );
  }
}

class _AppBarUserTitle extends StatelessWidget {
  final User user;
  const _AppBarUserTitle({required this.user});

  @override
  Widget build(BuildContext context) {
    final name = user.name.isNotEmpty ? user.name : user.userName;
    final nameStyle = Theme.of(context).textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w700,
          fontSize: 22,
          color: Theme.of(context).colorScheme.onSurface,
        );

    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: () => Navigator.pushNamed(context, AppRoutes.profileDetails),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          UserAvatar(user: user, fetchReadSas: (_) async => null, radius: 22),
          const SizedBox(width: 16),
          ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.55,
            ),
            child:
                Text(name, style: nameStyle, overflow: TextOverflow.ellipsis),
          ),
        ],
      ),
    );
  }
}

class _GreetingCard extends StatelessWidget {
  final User user;
  const _GreetingCard({required this.user});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final displayName = (user.name.isNotEmpty ? user.name : user.userName);
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ThemeColors.getContainerBackgroundColor(context),
        borderRadius: BorderRadius.circular(20.0),
        border: Border.all(
          color: const Color.fromARGB(255, 185, 210, 231),
          width: 2.0,
        ),
      ),
      padding: const EdgeInsets.all(16.0),
      child: Center(
        child: Text(
          loc.welcomeGroupView(
            displayName.isEmpty
                ? 'User'
                : displayName[0].toUpperCase() + displayName.substring(1),
          ),
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            fontFamily: 'lato',
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final onSurface = Theme.of(context).colorScheme.onSurface;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      child: Row(
        children: [
          Container(
            width: 6,
            height: 24,
            decoration: BoxDecoration(
              color: primary,
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: onSurface,
                ),
          ),
        ],
      ),
    );
  }
}

class _ChangeViewRow extends StatefulWidget {
  const _ChangeViewRow({Key? key}) : super(key: key);
  @override
  State<_ChangeViewRow> createState() => _ChangeViewRowState();
}

class _ChangeViewRowState extends State<_ChangeViewRow> {
  final _axis = ValueNotifier<Axis>(Axis.vertical);

  @override
  void dispose() {
    _axis.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(loc.changeView, style: const TextStyle(fontSize: 12)),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: () {
              _axis.value = _axis.value == Axis.vertical
                  ? Axis.horizontal
                  : Axis.vertical;
              GroupListSection.axisOverride.value = _axis.value;
            },
            child: const Icon(Icons.dashboard),
          ),
        ],
      ),
    );
  }
}
