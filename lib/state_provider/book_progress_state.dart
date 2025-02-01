
class BookProgressState {
  final String? currentBookId;
  final int currentPage;

  BookProgressState({this.currentBookId, this.currentPage = 0});

  BookProgressState copyWith({String? currentBookId, int? currentPage}) {
    return BookProgressState(
      currentBookId: currentBookId ?? this.currentBookId,
      currentPage: currentPage ?? this.currentPage,
    );
  }
}