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

/*   @override
  String toString() {
    if (isOpen24Hours) {
      return 'Abierto 24 horas';
    }
    return 'Abre: Día $openDay, $openHour:$openMinute - Cierra: Día $closeDay, $closeHour:$closeMinute';
  }
 */
  @override
  String toString() {
    // Si está abierto las 24 horas
    if (isOpen24Hours) {
      return 'Abierto 24 horas';
    }

    // Convertir las horas y minutos a formato HH:mm
    String formatTime(int hour, int minute) =>
        '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';

    String openTime = formatTime(openHour, openMinute);
    String closeTime = formatTime(closeHour, closeMinute);

    // Si abre y cierra el mismo día
    if (openDay == closeDay) {
      return 'Abre $openTime - Cierra $closeTime';
    }

    // Si abre un día y cierra en otro
    return 'Abre $openTime - Cierra $closeTime';
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

  bool isOpenForEntireRange(String timeRange) {
    if (isOpen24Hours) {
      return true; // Siempre abierto si está marcado como 24 horas
    }

    // Dividir el rango en inicio y fin
    final parts = timeRange.split('*');
    if (parts.length != 2) {
      throw ArgumentError(
          'El rango de tiempo debe tener el formato correcto: inicio*fin');
    }

    final startTime = DateTime.parse(parts[0]);
    final endTime = DateTime.parse(parts[1]);

    // Asegurarse de que el rango sea válido
    if (startTime.isAfter(endTime)) {
      throw ArgumentError(
          'La hora de inicio no puede ser posterior a la hora de fin.');
    }

    // Verificar si el rango completo está dentro del horario de apertura
    return _isOpenAt(startTime) && _isOpenAt(endTime);
  }

// Función auxiliar para verificar si está abierto en un momento específico
  bool _isOpenAt(DateTime dateTime) {
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
