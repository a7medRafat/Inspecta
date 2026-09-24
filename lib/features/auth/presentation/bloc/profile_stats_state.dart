part of 'profile_stats_cubit.dart';

class ProfileStatsState extends Equatable {
  final int? quotesSentThisMonth;
  final int? acceptedThisMonth;
  final int? clientsCount;

  const ProfileStatsState({this.quotesSentThisMonth, this.acceptedThisMonth, this.clientsCount});

  ProfileStatsState copyWith({int? quotesSentThisMonth, int? acceptedThisMonth, int? clientsCount}) {
    return ProfileStatsState(
      quotesSentThisMonth: quotesSentThisMonth ?? this.quotesSentThisMonth,
      acceptedThisMonth: acceptedThisMonth ?? this.acceptedThisMonth,
      clientsCount: clientsCount ?? this.clientsCount,
    );
  }

  @override
  List<Object?> get props => [quotesSentThisMonth, acceptedThisMonth, clientsCount];
}
