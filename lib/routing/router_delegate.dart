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
    routeState.addListener(notifyListeners);
  }

  @override
  Widget build(BuildContext context) => builder(context);

  @override
  Future<void> setNewRoutePath(PostRoutePath configuration) async {
    routeState.route = configuration;
    return SynchronousFuture(null);
  }

  @override
  PostRoutePath get currentConfiguration => routeState.route;

  @override
  void dispose() {
    routeState.removeListener(notifyListeners);
    routeState.dispose();
    super.dispose();
  }
}
