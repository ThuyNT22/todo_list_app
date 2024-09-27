class PaginationService {
  final int tasksPerPage = 10;  // Define how many tasks per page

  // Get paginated tasks
  List<T> getPaginatedTasks<T>(List<T> tasks, int currentPage) {
    int startIndex = (currentPage - 1) * tasksPerPage;
    int endIndex = startIndex + tasksPerPage;
    return tasks.sublist(startIndex, endIndex > tasks.length ? tasks.length : endIndex);
  }

  bool hasNextPage(List tasks, int currentPage) {
    return currentPage * tasksPerPage < tasks.length;
  }

  bool hasPreviousPage(int currentPage) {
    return currentPage > 1;
  }
}
