import '../models/post.dart';

/// Represents the various states of the post feature.
sealed class PostState {
  const PostState();
}

/// The initial state before any data is loaded.
final class PostInitial extends PostState {
  const PostInitial();
}

/// The state when data is currently being loaded.
final class PostLoading extends PostState {
  const PostLoading();
}

/// The state when posts have been successfully loaded.
final class PostLoaded extends PostState {
  /// The list of loaded posts.
  final List<Post> posts;

  const PostLoaded(this.posts);
}

/// The state when an error occurs.
final class PostError extends PostState {
  /// The error message.
  final String message;

  const PostError(this.message);
}
