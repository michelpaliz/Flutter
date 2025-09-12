import 'package:calendar_app_frontend/a-models/group_model/client/client.dart';
import 'package:calendar_app_frontend/a-models/group_model/group/group.dart';
import 'package:calendar_app_frontend/a-models/group_model/service/service.dart';
import 'package:calendar_app_frontend/b-backend/api/client/client_api.dart';
import 'package:calendar_app_frontend/b-backend/api/services/services_api.dart';
import 'package:calendar_app_frontend/f-themes/themes/theme_colors.dart';
import 'package:flutter/material.dart';

import 'sheets/add_client_sheet.dart';
import 'sheets/add_service_sheet.dart';
import 'tabs/clients_tab.dart';
import 'tabs/services_tab.dart';

class ServicesClientsScreen extends StatefulWidget {
  final Group group;
  const ServicesClientsScreen({super.key, required this.group});

  @override
  State<ServicesClientsScreen> createState() => _ServicesClientsScreenState();
}

class _ServicesClientsScreenState extends State<ServicesClientsScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tab;

  final _clientsApi = ClientsApi();
  final _servicesApi = ServicesApi();

  List<Client> _clients = [];
  List<Service> _services = [];
  bool _loadingClients = true, _loadingServices = true;
  String? _errClients, _errServices;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this);
    _loadClients();
    _loadServices();
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  Future<void> _loadClients() async {
    setState(() {
      _loadingClients = true;
      _errClients = null;
    });
    try {
      final data = await _clientsApi.list(groupId: widget.group.id);
      setState(() => _clients = data);
    } catch (e) {
      setState(() => _errClients = e.toString());
    } finally {
      if (mounted) setState(() => _loadingClients = false);
    }
  }

  Future<void> _loadServices() async {
    setState(() {
      _loadingServices = true;
      _errServices = null;
    });
    try {
      final data = await _servicesApi.list(groupId: widget.group.id);
      setState(() => _services = data);
    } catch (e) {
      setState(() => _errServices = e.toString());
    } finally {
      if (mounted) setState(() => _loadingServices = false);
    }
  }

  // ---------- Create flows ----------
  Future<void> _openAddClient() async {
    final created = await showModalBottomSheet<Client>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) =>
          AddClientSheet(groupId: widget.group.id, api: _clientsApi),
    );
    if (created != null && mounted) {
      setState(() => _clients.insert(0, created));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Client created: ${created.name}')),
      );
    }
  }

  Future<void> _openAddService() async {
    final created = await showModalBottomSheet<Service>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) =>
          AddServiceSheet(groupId: widget.group.id, api: _servicesApi),
    );
    if (created != null && mounted) {
      setState(() => _services.insert(0, created));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Service created: ${created.name}')),
      );
    }
  }

  // ---------- Edit flows ----------
  Future<void> _openEditClient(Client c) async {
    final updated = await showModalBottomSheet<Client>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => AddClientSheet(
        groupId: widget.group.id, // used only on create; harmless here
        api: _clientsApi,
        client: c, // tells the sheet it's edit mode
      ),
    );

    if (updated != null && mounted) {
      setState(() {
        final i = _clients.indexWhere((x) => x.id == updated.id);
        if (i != -1) _clients[i] = updated;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Client updated: ${updated.name}')),
      );
    }
  }

  Future<void> _openEditService(Service s) async {
    final updated = await showModalBottomSheet<Service>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => AddServiceSheet(
        groupId: widget.group.id,
        api: _servicesApi,
        service: s, // edit mode
      ),
    );

    if (updated != null && mounted) {
      setState(() {
        final i = _services.indexWhere((x) => x.id == updated.id);
        if (i != -1) _services[i] = updated;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Service updated: ${updated.name}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    // Colors driven by your ThemeColors helpers
    final primary = cs.primary;
    final selectedText = ThemeColors.getContrastTextColor(context, primary);
    final unselectedText = ThemeColors.getTextColor(context).withOpacity(0.7);
    final trackBg = ThemeColors.getCardBackgroundColor(context); // pill track

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: Navigator.of(context).canPop(),
        title: const Text('Services & Clients'),
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: Container(
              height: 40,
              decoration: BoxDecoration(
                color: trackBg,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: cs.onSurface.withOpacity(0.06)),
              ),
              child: TabBar(
                controller: _tab,
                tabs: const [Tab(text: 'Clients'), Tab(text: 'Services')],
                indicatorSize: TabBarIndicatorSize.tab,
                dividerColor: Colors.transparent,
                labelColor: selectedText,
                unselectedLabelColor: unselectedText,
                labelStyle: theme.textTheme.labelLarge,
                unselectedLabelStyle: theme.textTheme.labelLarge,
                indicator: BoxDecoration(
                  color: primary,
                  borderRadius: BorderRadius.circular(10),
                ),
                splashBorderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tab,
        children: [
          ClientsTab(
            items: _clients,
            loading: _loadingClients,
            error: _errClients,
            onRefresh: _loadClients,
            showInlineCTA: false,
            onEdit: _openEditClient, // 👈 wire tap-to-edit
          ),
          ServicesTab(
            items: _services,
            loading: _loadingServices,
            error: _errServices,
            onRefresh: _loadServices,
            showInlineCTA: false,
            onEdit: _openEditService, // 👈 wire tap-to-edit
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: SizedBox(
          height: 56,
          child: FilledButton.icon(
            icon: const Icon(Icons.add),
            label: AnimatedBuilder(
              animation: _tab,
              builder: (_, __) =>
                  Text(_tab.index == 0 ? 'Add Client' : 'Add Service'),
            ),
            onPressed: () =>
                _tab.index == 0 ? _openAddClient() : _openAddService(),
          ),
        ),
      ),
    );
  }
}
