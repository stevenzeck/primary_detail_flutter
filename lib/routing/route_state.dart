import 'package:flutter/widgets.dart';

import '../model/post.dart';
import '../routing.dart';

class RouteState extends ChangeNotifier {
  final PostRouteInformationParser _parser;
  PostRoutePath _route;
  List<Post>? posts;

  RouteState(this._parser) : _route = _parser.initialRoute;

  PostRoutePath get route => _route;

  @override
  void notifyListeners() {
    super.notifyListeners();
  }

  set route(PostRoutePath route) {
    if (_route == route) return;

    _route = route;
    notifyListeners();
  }

  Future<void> go(String route) async {
    this.route =
        await _parser.parseRouteInformation(RouteInformation(location: route));
  }
}

class RouteStateScope extends InheritedNotifier<RouteState> {
  const RouteStateScope({
    required super.notifier,
    required super.child,
    super.key,
  });

  static RouteState of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<RouteStateScope>()!.notifier!;
}
