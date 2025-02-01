import 'package:one_verse/models/generic_book.dart';

class LibraryState {
  final String? selectedFolder;
  final List<GenericBook> books;

  LibraryState({this.selectedFolder, this.books = const []});

  LibraryState copyWith({String? selectedFolder, List<GenericBook>? books}) {
    return LibraryState(
      selectedFolder: selectedFolder ?? this.selectedFolder,
      books: books ?? this.books,
    );
  }
}
