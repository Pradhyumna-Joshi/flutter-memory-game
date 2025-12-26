class Game {
  final int index;
  final String imageURL;
  final bool isComplete;

  Game({required this.index, required this.imageURL, required this.isComplete});

  Game copyWith({int? index, String? imageURL, bool? isComplete}) {
    return Game(
      index: index ?? this.index,
      imageURL: imageURL ?? this.imageURL,
      isComplete: isComplete ?? this.isComplete,
    );
  }
}
