import 'package:equatable/equatable.dart';

abstract class Entity extends Equatable {
  const Entity();

  Entity copyWith();

  @override
  List<Object?> get props;
}
