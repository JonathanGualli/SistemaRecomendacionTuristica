class OpeningPeriod {
  final int openDay;
  final int openHour;
  final int openMinute;
  final int closeDay;
  final int closeHour;
  final int closeMinute;
  final bool isOpen24Hours; // Nuevo atributo

  OpeningPeriod({
    required this.openDay,
    required this.openHour,
    required this.openMinute,
    required this.closeDay,
    required this.closeHour,
    required this.closeMinute,
    this.isOpen24Hours = false, // Valor por defecto si no está abierto 24 horas
  });

  @override
  String toString() {
    if (isOpen24Hours) {
      return 'Abierto 24 horas';
    }
    return 'Abre: Día $openDay, $openHour:$openMinute - Cierra: Día $closeDay, $closeHour:$closeMinute';
  }

  bool isOpenAt(DateTime dateTime) {
    if (isOpen24Hours) {
      return true; // Siempre abierto si está marcado como 24 horas
    }

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
