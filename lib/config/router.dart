import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/widgets/adaptive_layout.dart';

part 'router.g.dart';

/// Configures the application's router using GoRouter.
final GoRouter router = GoRouter(initialLocation: '/posts', routes: $appRoutes);

@TypedGoRoute<PostsRoute>(
  path: '/posts',
  routes: [TypedGoRoute<PostDetailRoute>(path: ':postId')],
)
class PostsRoute extends GoRouteData with $PostsRoute {
  const PostsRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const AdaptiveLayout(selectedPostId: null);
  }
}

class PostDetailRoute extends GoRouteData with $PostDetailRoute {
  final int postId;

  const PostDetailRoute({required this.postId});

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return AdaptiveLayout(selectedPostId: postId);
  }
}
