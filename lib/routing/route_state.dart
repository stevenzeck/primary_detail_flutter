import 'package:flutter/widgets.dart';

import '../model/post.dart';
import '../routing.dart';

class RouteState extends ChangeNotifier {
  final PostRouteInformationParser _parser;
  PostRoutePath _route;
  List<Post>? posts;

  RouteState(this._parser) : _route = _parser.initialRoute;

  // Getter method for the route
  PostRoutePath get route => _route;

  // Setter method for the route
  set route(PostRoutePath route) {
    if (_route == route) return;

    _route = route;
    notifyListeners();
  }

  // Navigate to the specified route
  Future<void> go(String route) async {
    this.route = await _parser.parseRouteInformation(
      RouteInformation(uri: Uri.parse(route)),
    );
  }
}

class RouteStateScope extends InheritedNotifier<RouteState> {
  const RouteStateScope({
    required super.notifier, // Type casting for InheritedNotifier
    required super.child,
    super.key, // Declare Key as nullable
  });

  // Returns the RouteState instance from the widget tree
  static RouteState of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<RouteStateScope>()!.notifier!;
}
