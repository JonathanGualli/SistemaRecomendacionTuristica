class OpeningPeriod {
  final int openDay;
  final int openHour;
  final int openMinute;
  final int closeDay;
  final int closeHour;
  final int closeMinute;

  OpeningPeriod({
    required this.openDay,
    required this.openHour,
    required this.openMinute,
    required this.closeDay,
    required this.closeHour,
    required this.closeMinute,
  });

  @override
  String toString() {
    return 'Abre: Día $openDay, $openHour:$openMinute - Cierra: Día $closeDay, $closeHour:$closeMinute';
  }

  bool isOpenAt(DateTime dateTime) {
    final day = dateTime.weekday % 7; // 0 para domingo, 1 para lunes, etc.
    final hour = dateTime.hour;
    final minute = dateTime.minute;

    if (day == openDay) {
      if (hour > openHour || (hour == openHour && minute >= openMinute)) {
        if (day == closeDay) {
          return hour < closeHour ||
              (hour == closeHour && minute < closeMinute);
        }
        return true;
      }
    } else if (day == closeDay) {
      return hour < closeHour || (hour == closeHour && minute < closeMinute);
    }
    return false;
  }
}
