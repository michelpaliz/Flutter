import 'package:first_project/a-models/user.dart';
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
          double offset = _animationController.value *
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
      height: 80, // Adjust height as needed
      child: PageView.builder(
        controller: _pageController,
        // PageController(viewportFraction: 0.8), // Adjust viewportFraction
        scrollDirection: Axis.horizontal,
        itemCount: widget.users.length,
        itemBuilder: (context, index) {
          User user = widget.users[index];
          return Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: 4.0, vertical: 4), // Adjust padding
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white, // Background color
                borderRadius: BorderRadius.circular(6.0), // Rounded corners
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 3.0,
                    offset: Offset(1, 1), // Shadow offset
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min, // Adjust size to fit content
                children: [
                  SizedBox(height: 6.0),
                  CircleAvatar(
                    radius: 20, // Adjust size as needed
                    backgroundImage:
                        user.photoUrl != null && user.photoUrl!.isNotEmpty
                            ? NetworkImage(user.photoUrl!)
                            : AssetImage('assets/images/default_profile.png')
                                as ImageProvider,
                  ),
                  SizedBox(height: 4.0), // Space between photo and name
                  Text(user.userName,
                      style: TextStyle(
                          fontSize: 12.0)), // Display userName below the photo
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
