class ApiEndpoints {
  const ApiEndpoints._();
  static const login = '/api/v1/auth/login';
  static const register = '/api/v1/auth/register';
  static const refresh = '/api/v1/auth/refresh';
  static const logout = '/api/v1/auth/logout';
  static const me = '/api/v1/users/me';
  static const dashboard = '/api/v1/dashboard';
  static const reviewSummary = '/api/v1/reviews/summary';
  static const reviewDue = '/api/v1/reviews/due';
  static const wrongQuestions = '/api/v1/reviews/wrong-questions';
  static String learningPath(String language) =>
      '/api/v1/learning-path/$language';
  static String myLearningPath(String language) =>
      '/api/v1/learning-path/$language/me';
  static String grammarPoint(int id) => '/api/v1/grammar-points/$id';
  static String grammarPointLessons(int id) =>
      '/api/v1/grammar-points/$id/lessons';
  static String lesson(int id) => '/api/v1/lessons/$id';
  static String lessonQuestions(int id) => '/api/v1/lessons/$id/questions';
  static String submitAnswer(int id) => '/api/v1/questions/$id/answer';
  static String completeLesson(int id) => '/api/v1/lessons/$id/complete';
  static String reviewAnswer(int id) => '/api/v1/reviews/questions/$id/answer';
}
