import '../../../data/models/patient_model.dart';

class DashboardMetrics {
  const DashboardMetrics({
    required this.patientCount,
    required this.doctorCount,
    required this.appointmentCount,
    required this.unreadNotifications,
    required this.weeklyAppointments,
    required this.appointmentStatusCounts,
    required this.riskLevelCounts,
  });

  final int patientCount;
  final int doctorCount;
  final int appointmentCount;
  final int unreadNotifications;
  final List<DayMetric> weeklyAppointments;
  final Map<String, int> appointmentStatusCounts;
  final Map<String, int> riskLevelCounts;
}

class DayMetric {
  const DayMetric({required this.label, required this.value});
  final String label;
  final double value;
}

DashboardMetrics buildDashboardMetrics({
  required List<PatientModel> patients,
  required List<DoctorModel> doctors,
  required List<AppointmentModel> appointments,
  required List<NotificationModel> notifications,
  required Map<String, int> riskLevelCounts,
}) {
  final now = DateTime.now();
  final weekStart = DateTime(now.year, now.month, now.day).subtract(Duration(days: now.weekday - 1));

  final weekly = List.generate(7, (i) {
    final day = weekStart.add(Duration(days: i));
    final label = _weekdayShort(day.weekday);
    final count = appointments.where((a) {
      final dt = DateTime.tryParse(a.scheduledAt);
      if (dt == null) return false;
      final local = DateTime(dt.year, dt.month, dt.day);
      return local == day;
    }).length;
    return DayMetric(label: label, value: count.toDouble());
  });

  final statusCounts = <String, int>{};
  for (final a in appointments) {
    final key = _statusLabel(a.status);
    statusCounts[key] = (statusCounts[key] ?? 0) + 1;
  }

  final unread = notifications.where((n) => n.status.toUpperCase() == 'UNREAD').length;

  return DashboardMetrics(
    patientCount: patients.length,
    doctorCount: doctors.length,
    appointmentCount: appointments.length,
    unreadNotifications: unread,
    weeklyAppointments: weekly,
    appointmentStatusCounts: statusCounts,
    riskLevelCounts: riskLevelCounts,
  );
}

String _weekdayShort(int weekday) => switch (weekday) {
      1 => 'Lun',
      2 => 'Mar',
      3 => 'Mer',
      4 => 'Jeu',
      5 => 'Ven',
      6 => 'Sam',
      7 => 'Dim',
      _ => '?',
    };

String _statusLabel(String status) => switch (status.toUpperCase()) {
      'CONFIRMED' => 'Confirmés',
      'SCHEDULED' => 'Planifiés',
      'COMPLETED' => 'Terminés',
      'CANCELLED' => 'Annulés',
      _ => status,
    };
