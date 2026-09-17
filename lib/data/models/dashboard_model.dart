class DashboardSummary {
  final double totalRevenue;
  final int totalTickets;
  final int totalUsers;
  final int activeMovies;
  final List<DailyRevenuePoint> dailyRevenue;
  final List<BookingStatusDistribution> bookingStatusDistribution;
  final List<TopMovie> topMovies;
  final List<UserGrowth> userGrowth;
  final List<CinemaPerformance> cinemaPerformance;

  DashboardSummary({
    required this.totalRevenue,
    required this.totalTickets,
    required this.totalUsers,
    required this.activeMovies,
    required this.dailyRevenue,
    required this.bookingStatusDistribution,
    required this.topMovies,
    required this.userGrowth,
    required this.cinemaPerformance,
  });

  factory DashboardSummary.fromJson(Map<String, dynamic> json) {
    return DashboardSummary(
      totalRevenue: (json['totalRevenue'] ?? 0).toDouble(),
      totalTickets: json['totalTickets'] ?? 0,
      totalUsers: json['totalUsers'] ?? 0,
      activeMovies: json['activeMovies'] ?? 0,
      dailyRevenue: (json['dailyRevenue'] as List<dynamic>? ?? [])
          .map((e) => DailyRevenuePoint.fromJson(e))
          .toList(),
      bookingStatusDistribution:
          (json['bookingStatusDistribution'] as List<dynamic>? ?? [])
              .map((e) => BookingStatusDistribution.fromJson(e))
              .toList(),
      topMovies: (json['topMovies'] as List<dynamic>? ?? [])
          .map((e) => TopMovie.fromJson(e))
          .toList(),
      userGrowth: (json['userGrowth'] as List<dynamic>? ?? [])
          .map((e) => UserGrowth.fromJson(e))
          .toList(),
      cinemaPerformance: (json['cinemaPerformance'] as List<dynamic>? ?? [])
          .map((e) => CinemaPerformance.fromJson(e))
          .toList(),
    );
  }
}

class DailyRevenuePoint {
  final DateTime date;
  final double revenue;

  DailyRevenuePoint({required this.date, required this.revenue});

  factory DailyRevenuePoint.fromJson(Map<String, dynamic> json) {
    return DailyRevenuePoint(
      date: DateTime.parse(json['date']),
      revenue: (json['revenue'] ?? 0).toDouble(),
    );
  }
}

class BookingStatusDistribution {
  final String status;
  final int count;
  final double percentage;

  BookingStatusDistribution({
    required this.status,
    required this.count,
    required this.percentage,
  });

  factory BookingStatusDistribution.fromJson(Map<String, dynamic> json) {
    return BookingStatusDistribution(
      status: json['status'] ?? '',
      count: json['count'] ?? 0,
      percentage: (json['percentage'] ?? 0).toDouble(),
    );
  }
}

class TopMovie {
  final String movieId;
  final String title;
  final int ticketsSold;
  final double revenue;

  TopMovie({
    required this.movieId,
    required this.title,
    required this.ticketsSold,
    required this.revenue,
  });

  factory TopMovie.fromJson(Map<String, dynamic> json) {
    return TopMovie(
      movieId: json['movieId'] ?? '',
      title: json['title'] ?? '',
      ticketsSold: json['ticketsSold'] ?? 0,
      revenue: (json['revenue'] ?? 0).toDouble(),
    );
  }
}

class UserGrowth {
  final int year;
  final int month;
  final int newUsers;

  UserGrowth({required this.year, required this.month, required this.newUsers});

  factory UserGrowth.fromJson(Map<String, dynamic> json) {
    return UserGrowth(
      year: json['year'] ?? 0,
      month: json['month'] ?? 0,
      newUsers: json['newUsers'] ?? 0,
    );
  }
}

class CinemaPerformance {
  final String cinemaId;
  final String cinemaName;
  final double occupancyRate;

  CinemaPerformance({
    required this.cinemaId,
    required this.cinemaName,
    required this.occupancyRate,
  });

  factory CinemaPerformance.fromJson(Map<String, dynamic> json) {
    return CinemaPerformance(
      cinemaId: json['cinemaId'] ?? '',
      cinemaName: json['cinemaName'] ?? '',
      occupancyRate: (json['occupancyRate'] ?? 0).toDouble(),
    );
  }
}
