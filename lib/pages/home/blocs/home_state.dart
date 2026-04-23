part of 'home_cubit.dart';

@freezed
abstract class HomeState with _$HomeState {

  const factory HomeState.initial() = InitialHomeState;

  const factory HomeState.loading() = LoadingHomeState;

  const factory HomeState.loaded({
    required List<Post> posts,
  }) = LoadedHomeState;

  const factory HomeState.error({
    required HomeError error,
  }) = ErrorHomeState;
  
}
