class HomeRepository {
  Future<Map<String, dynamic>> loadDashboard() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return {
      'onlineTrips': 18,
      'rating': 4.9,
      'earnings': 12450,
      'todayTrips': 6,
    };
  }
}
