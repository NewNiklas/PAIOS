import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:hive_flutter/hive_flutter.dart';

class ResourceRepository {
  final VoidCallback notifyEngine;

  List<Map<String, dynamic>> resources = [];

  ResourceRepository({required this.notifyEngine});

  Future<void> initFromHive(String url) async {
    final box = Hive.box('paios_storage');

    // Step 1: Cache
    final String? cached = box.get("cached_resources_json");
    if (cached != null) {
      resources = List<Map<String, dynamic>>.from(
        (jsonDecode(cached) as List).map((e) => Map<String, dynamic>.from(e)),
      );
    } else {
      // Step 2: Bundle fallback
      try {
        final raw = await rootBundle.loadString('assets/additional_resources.json');
        resources = List<Map<String, dynamic>>.from(
          (jsonDecode(raw) as List).map((e) => Map<String, dynamic>.from(e)),
        );
      } catch (_) {}
    }

    // Step 3: Network refresh and cache update
    if (!kDebugMode) {
      try {
        final response = await http.get(Uri.parse("$url/assets/additional_resources.json"));
        if (response.statusCode == 200) {
          final fetched = List<Map<String, dynamic>>.from(
            (jsonDecode(response.body) as List).map((e) => Map<String, dynamic>.from(e)),
          );
          resources = fetched;
          box.put("cached_resources_json", response.body);
          notifyEngine();
        }
      } catch (_) {
        // Silent fallback — already loaded from cache or bundle
      }
    }
  }

  /// Returns resources grouped by collection, filtered by type == "link"
  Map<String, List<Map<String, dynamic>>> get grouped {
    final Map<String, List<Map<String, dynamic>>> out = {};
    for (final r in resources) {
      if (r["type"] == "link") {
        final collection = r["collection"] as String? ?? "Other";
        out.putIfAbsent(collection, () => []).add(r);
      }
    }
    return out;
  }
}
