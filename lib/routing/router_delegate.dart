import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import '../routing.dart';

class PostRouterDelegate extends RouterDelegate<PostRoutePath>
    with ChangeNotifier, PopNavigatorRouterDelegateMixin<PostRoutePath> {
  final RouteState routeState;
  final WidgetBuilder builder;

  @override
  final GlobalKey<NavigatorState> navigatorKey;

  PostRouterDelegate({
    required this.routeState,
    required this.builder,
    required this.navigatorKey,
  }) {
    routeState
        .addListener(notifyListeners); // Add notifyListeners as a listener
  }

  // Build the widget to display based on the current route
  @override
  Widget build(BuildContext context) => builder(context);

  // Set the new route path for the routeState
  @override
  Future<void> setNewRoutePath(PostRoutePath configuration) async {
    routeState.route = configuration;
    return SynchronousFuture(null);
  }

  // Get the current route from the routeState
  @override
  PostRoutePath get currentConfiguration => routeState.route;

  // Clean up resources and remove the listener when the delegate is disposed
  @override
  void dispose() {
    routeState.removeListener(notifyListeners);
    routeState.dispose();
    super.dispose();
  }
}
