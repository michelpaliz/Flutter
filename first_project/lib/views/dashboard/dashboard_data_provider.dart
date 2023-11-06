
// Higher-level ancestor widget that provides the necessary data using Provider
import 'package:first_project/views/service_provider/provider_management.dart';
import 'package:first_project/views/service_provider/provider_management_data.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DashboardDataProvider extends StatelessWidget {
  final Widget child;
  final ProviderManagement providerManagement;

  DashboardDataProvider({
    required this.child,
    required this.providerManagement,
  });

  @override
  Widget build(BuildContext context) {
    return Provider<ProviderManagementData>(
      create: (context) => ProviderManagementData(providerManagement),
      child: child,
    );
  }
}