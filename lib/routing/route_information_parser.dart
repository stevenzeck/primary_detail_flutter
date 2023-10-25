import 'package:flutter/widgets.dart';
import 'package:path_to_regexp/path_to_regexp.dart';

import 'route_path.dart';

class PostRouteInformationParser extends RouteInformationParser<PostRoutePath> {
  final PostRoutePath initialRoute;
  final List<String> _pathTemplates;

  PostRouteInformationParser({
    required List<String> allowedPaths,
    String initialRoute = '/',
  })  : initialRoute = PostRoutePath(initialRoute, initialRoute, {}, {}),
        _pathTemplates = allowedPaths;

  // Parse route information and return a PostRoutePath object
  @override
  Future<PostRoutePath> parseRouteInformation(
      RouteInformation routeInformation) async {
    final path = routeInformation.location!;
    final queryParams = Uri.parse(path).queryParameters;
    var parsedRoute = initialRoute;

    for (var pathTemplate in _pathTemplates) {
      final parameters = <String>[];
      var pathRegExp = pathToRegExp(pathTemplate, parameters: parameters);
      final match = pathRegExp.matchAsPrefix(path);

      if (match != null) {
        final params = extract(parameters, match);
        parsedRoute = PostRoutePath(path, pathTemplate, params, queryParams);
        break;
      }
    }

    return parsedRoute;
  }

  // Restore route information from a given PostRoutePath object
  @override
  RouteInformation restoreRouteInformation(PostRoutePath configuration) =>
      RouteInformation(location: configuration.path);
}
