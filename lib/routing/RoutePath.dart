class PostRoutePath {
  final int id;
  final bool isUnknown;

  PostRoutePath.home()
      : id = null,
        isUnknown = false;

  PostRoutePath.details(this.id) : isUnknown = false;

  PostRoutePath.unknown()
      : id = null,
        isUnknown = true;

  bool get isHomePage => id == null;

  bool get isDetailsPage => id != null;
}
