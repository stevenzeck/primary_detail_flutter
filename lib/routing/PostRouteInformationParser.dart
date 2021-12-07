import 'package:flutter/widgets.dart';

import 'RoutePath.dart';

class PostRouteInformationParser extends RouteInformationParser<PostRoutePath> {
  @override
  Future<PostRoutePath> parseRouteInformation(
      RouteInformation routeInformation) async {
    final uri = Uri.parse(routeInformation.location);
    // Handle '/'
    if (uri.pathSegments.length == 0) {
      return PostRoutePath.home();
    }

    // Handle '/post/:id'
    if (uri.pathSegments.length == 2) {
      if (uri.pathSegments[0] != 'post') return PostRoutePath.unknown();
      var remaining = uri.pathSegments[1];
      var id = int.tryParse(remaining);
      if (id == null) return PostRoutePath.unknown();
      return PostRoutePath.details(id);
    }

    // Handle unknown routes
    return PostRoutePath.unknown();
  }

  @override
  RouteInformation restoreRouteInformation(PostRoutePath path) {
    if (path.isUnknown) {
      return RouteInformation(location: '/404');
    }
    if (path.isHomePage) {
      return RouteInformation(location: '/');
    }
    if (path.isDetailsPage) {
      return RouteInformation(location: '/post/${path.id}');
    }
    return null;
  }
}
