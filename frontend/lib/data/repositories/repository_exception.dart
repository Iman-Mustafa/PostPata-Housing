class RepositoryException implements Exception {
  final String message;
  
  RepositoryException(this.message);
  
  @override
  String toString() => message;
}