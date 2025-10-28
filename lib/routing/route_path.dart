class PostRoutePath {
  final String path;

  final String pathTemplate;

  final Map<String, String> parameters;

  final Map<String, String> queryParameters;

  PostRoutePath(
    this.path,
    this.pathTemplate,
    this.parameters,
    this.queryParameters,
  );
}
