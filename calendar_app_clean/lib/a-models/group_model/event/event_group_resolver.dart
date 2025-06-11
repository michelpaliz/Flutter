import 'package:first_project/a-models/group_model/event/event.dart';
import 'package:first_project/a-models/group_model/group/group.dart';
import 'package:first_project/b-backend/api/event/event_services.dart';

// Think of it as: “get me the initial version of this group's data from the server, with some caching.”
// It's only updated once per group, unless clearGroup() or clearAll() is called.
// It does not handle changes like edits, deletes, or new events.

class GroupEventResolver {
  final EventService _eventService = EventService();

  final Map<String, List<Event>> _cache = {};

  Future<List<Event>> getEventsForGroup(Group group) async {
    if (_cache.containsKey(group.id)) {
      return _cache[group.id]!;
    }

    final events = await _eventService.getEventsByGroupId(group.id);
    _cache[group.id] = events;
    return events;
  }

  void clearGroup(String groupId) {
    _cache.remove(groupId);
  }

  void clearAll() {
    _cache.clear();
  }

  void updateCache(String groupId, List<Event> updatedEvents) {
    _cache[groupId] = updatedEvents;
  }
}
