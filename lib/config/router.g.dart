// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'router.dart';

// **************************************************************************
// GoRouterGenerator
// **************************************************************************

List<RouteBase> get $appRoutes => [$postsRoute];

RouteBase get $postsRoute => GoRouteData.$route(
  path: '/posts',
  factory: $PostsRoute._fromState,
  routes: [
    GoRouteData.$route(path: ':postId', factory: $PostDetailRoute._fromState),
  ],
);

mixin $PostsRoute on GoRouteData {
  static PostsRoute _fromState(GoRouterState state) => const PostsRoute();

  @override
  String get location => GoRouteData.$location('/posts');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

mixin $PostDetailRoute on GoRouteData {
  static PostDetailRoute _fromState(GoRouterState state) =>
      PostDetailRoute(postId: int.parse(state.pathParameters['postId']!));

  PostDetailRoute get _self => this as PostDetailRoute;

  @override
  String get location => GoRouteData.$location(
    '/posts/${Uri.encodeComponent(_self.postId.toString())}',
  );

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}
