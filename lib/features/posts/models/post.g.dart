// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Post _$PostFromJson(Map<String, dynamic> json) => Post(
  id: json['id'] as PostId,
  userId: json['userId'] as UserId,
  title: json['title'] as String,
  body: json['body'] as String,
  isRead: json['isRead'] == null
      ? false
      : Post._isReadFromDb((json['isRead'] as num).toInt()),
);

Map<String, dynamic> _$PostToJson(Post instance) => <String, dynamic>{
  'id': instance.id,
  'userId': instance.userId,
  'title': instance.title,
  'body': instance.body,
  'isRead': Post._isReadToDb(instance.isRead),
};
