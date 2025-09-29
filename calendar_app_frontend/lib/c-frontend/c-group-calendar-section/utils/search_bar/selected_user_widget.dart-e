import 'package:calendar_app_frontend/a-models/user_model/user.dart';
import 'package:calendar_app_frontend/f-themes/themes/theme_colors.dart';
import 'package:flutter/material.dart';

class AnimatedUsersList extends StatefulWidget {
  final List<User> users;

  AnimatedUsersList({required this.users});

  @override
  _AnimatedUsersListState createState() => _AnimatedUsersListState();
}

class _AnimatedUsersListState extends State<AnimatedUsersList>
    with SingleTickerProviderStateMixin {
  late final PageController _pageController;
  late final AnimationController _animationController;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    // _pageController = PageController();
    _pageController = PageController(viewportFraction: 0.8);

    _animationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 10), // Duration of the animation
    )..repeat();

    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.linear,
    );

    _startAutoScroll();
  }

  void _startAutoScroll() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _animationController.addListener(() {
        if (_pageController.hasClients) {
          double offset =
              _animationController.value *
              (_pageController.position.maxScrollExtent);
          _pageController.jumpTo(offset);
        }
      });
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      child: PageView.builder(
        controller: _pageController,
        scrollDirection: Axis.horizontal,
        itemCount: widget.users.length,
        itemBuilder: (context, index) {
          User user = widget.users[index];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 4),
            child: Container(
              decoration: BoxDecoration(
                color: ThemeColors.getCardBackgroundColor(
                  context,
                ), // ✅ Use card background color
                borderRadius: BorderRadius.circular(6.0),
                boxShadow: [
                  BoxShadow(
                    color: ThemeColors.getCardShadowColor(
                      context,
                    ), // ✅ Cleaner!
                    blurRadius: 3.0,
                    offset: const Offset(1, 1),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 6.0),
                  CircleAvatar(
                    radius: 20,
                    backgroundImage:
                        (user.photoUrl != null && user.photoUrl!.isNotEmpty)
                        ? NetworkImage(user.photoUrl!)
                        : const AssetImage('assets/images/default_profile.png')
                              as ImageProvider,
                  ),
                  const SizedBox(height: 4.0),
                  Text(
                    user.userName,
                    style: TextStyle(
                      fontSize: 12.0,
                      color: ThemeColors.getTextColor(
                        context,
                      ), // ✅ Text color based on theme
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
