import 'package:easy_date_timeline/easy_date_timeline.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:tesis_v2/providers/auth_provider.dart';
import 'package:tesis_v2/providers/preferences_provider.dart';
import 'package:tesis_v2/screens/profile_screen.dart';
import 'package:tesis_v2/screens/specific_poi_selection_screen.dart';
import 'package:tesis_v2/services/navigation_service.dart';
import 'package:tesis_v2/services/snackbar_service.dart';
import 'package:tesis_v2/utils/colors.dart';
import 'package:tesis_v2/utils/dimensions.dart';

class ScheduleSelectionScreen extends StatefulWidget {
  const ScheduleSelectionScreen({super.key});

  static const routeName = "/scheduleSelection";

  @override
  State<ScheduleSelectionScreen> createState() =>
      _ScheduleSelectionScreenState();
}

class _ScheduleSelectionScreenState extends State<ScheduleSelectionScreen> {
  AuthProvider? _auth;
  CalendarController calendarController = CalendarController();

  var dateNow = DateTime.now();
  var date = DateTime.now();
  TimeOfDay? startTime;
  TimeOfDay? endTime;

  @override
  Widget build(BuildContext context) {
    _auth = Provider.of<AuthProvider>(context);
    return Scaffold(
      body: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: Dimensions.screenHeight * 0.4,
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.purple,
              ),
              child: Column(
                children: [
                  AppBar(
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    leading: Padding(
                      padding: const EdgeInsets.only(left: 25),
                      child: GestureDetector(
                        child: const Icon(
                          Icons.arrow_back_ios,
                          color: Colors.white,
                          size: 30,
                        ),
                        onTap: () {
                          NavigationService.instance.goBack();
                        },
                      ),
                    ),
                    actions: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        child: GestureDetector(
                          child: CircleAvatar(
                            radius: 25,
                            backgroundColor: Colors.white,
                            child: ClipOval(
                              child: Image(
                                image: NetworkImage(_auth!.user!.photoURL!),
                                fit: BoxFit.cover,
                                //height: 80,
                                //width: 80,
                              ),
                            ),
                          ),
                          onTap: () {
                            NavigationService.instance
                                .navigatePushName(ProfileScreen.routeName);
                          },
                        ),
                      )
                    ],
                  ),
                  const Spacer(
                    flex: 1,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Muy bien, ${_auth!.user!.displayName!.split(" ")[0]}!',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Sigamos mejorando tu experiencia de viaje',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ),
                  const Spacer(
                    flex: 2,
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: (Dimensions.screenHeight * 0.4) * 0.80,
            left: 0,
            right: 0,
            child: Container(
              height: Dimensions.screenHeight,
              decoration: BoxDecoration(
                color: Colors.grey[350],
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(40),
                  topRight: Radius.circular(40),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 15.0),
                child: Align(
                  alignment: Alignment.topCenter,
                  child: Text(
                    '¿Que fecha y horario te gustaría?',
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: (Dimensions.screenHeight * 0.4) * 0.95,
            left: 0,
            right: 0,
            child: Container(
              height: Dimensions.screenHeight -
                  ((Dimensions.screenHeight * 0.4) * 0.95),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(40),
                  topRight: Radius.circular(40),
                ),
              ),
              child: Padding(
                padding: EdgeInsets.only(
                  left: Dimensions.screenWidth * 0.08,
                  right: Dimensions.screenWidth * 0.08,
                  top: Dimensions.screenHeight * 0.03,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    datePiker(),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10, top: 10),
                      child: Row(
                        children: [
                          const Text(
                            'Hora del itinerario:',
                            style: TextStyle(
                              fontSize: 23,
                              color: Colores.azul,
                            ),
                          ),
                          const Spacer(),
                          IconButton(
                            onPressed: () {
                              // Mostrar el diálogo informativo
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: const Text(
                                        'Información sobre los intervalos de tiempo'),
                                    content: const Text(
                                      'Para mayor facilidad, se trabajará solo con intervalos de 30 minutos. '
                                      'Esto significa que no se permiten minutos como 23, 14, etc. '
                                      'Solo puedes elegir 00, 30, 60, etc. para facilitar la planificación del itinerario.',
                                      style: TextStyle(fontSize: 16),
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                        child: const Text('Cerrar'),
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                            icon: const Icon(
                              Icons.help_outline,
                              color: Colores.morado,
                              size: 30,
                            ),
                          ),
                        ],
                      ),
                    ),
                    selectTime(context, 'start'),
                    selectTime(context, 'end'),
                    Expanded(
                      flex: 1,
                      child: Center(
                        child: SizedBox(
                          width: Dimensions.screenWidth * 0.75,
                          child: ElevatedButton(
                            /* onPressed: () async {
                              if (startTime == null || endTime == null) {
                                SnackBarService.instance.showSnackBar(
                                    "Por favor selecciona un horario correcto",
                                    false);
                              } else {
                                if (date.isAfter(dateNow
                                    .subtract(const Duration(days: 1)))) {
                                  PreferencesProvider.instance
                                      .setStartTime(startTime!);
                                  PreferencesProvider.instance
                                      .setEndTime(endTime!);
                                  PreferencesProvider.instance.setDate(date);
                                  NavigationService.instance.navigatePushName(
                                      SpecificPoiSelectionScreen.routeName);
                                } else {
                                  SnackBarService.instance.showSnackBar(
                                      "Por favor, selecciona una fecha correcta",
                                      false);
                                }
                                print(
                                  'Hora fin ${PreferencesProvider.instance.getEndTime()}',
                                );

                                print(
                                  'Hora inicio ${PreferencesProvider.instance.getStartTIme()}',
                                );

                                print(
                                  'Fecha recorrido ${PreferencesProvider.instance.getDate()}',
                                );

                                /* DateTime datahola =
                                    PreferencesProvider.instance.getDate();
                                print('Data de prueba ${datahola}');
                                TimeOfDay timestart = PreferencesProvider
                                    .instance
                                    .getStartTIme()!;
                                TimeOfDay timeend =
                                    PreferencesProvider.instance.getEndTime()!;

                                // Combinar Fecha con Hora inicio
                                DateTime fechaHoraInicio = DateTime(
                                  datahola.year,
                                  datahola.month,
                                  datahola.day,
                                  timestart.hour,
                                  timestart.minute,
                                );
                                print('Hora inicio final: $fechaHoraInicio');
/*                                 // Convertir a formato ISO 8601 en UTC
                                String isoInicio =
                                    fechaHoraInicio.toUtc().toIso8601String();
                                print('Hora inicio en formato ISO: $isoInicio'); */

                                // Convertir a formato ISO 8601 sin convertir a UTC
                                String isoInicio =
                                    fechaHoraInicio.toIso8601String() + 'Z';

                                print('Hora inicio en formato ISO: $isoInicio'); */
                              }
                            }, */
                            onPressed: () async {
                              if (startTime == null || endTime == null) {
                                SnackBarService.instance.showSnackBar(
                                  "Por favor selecciona un horario correcto",
                                  false,
                                );
                              } else {
                                // Combinar fecha seleccionada con hora de inicio y fin
                                DateTime startDateTime = DateTime(
                                  date.year,
                                  date.month,
                                  date.day,
                                  startTime!.hour,
                                  startTime!.minute,
                                );
                                DateTime endDateTime = DateTime(
                                  date.year,
                                  date.month,
                                  date.day,
                                  endTime!.hour,
                                  endTime!.minute,
                                );

                                // Obtener la fecha y hora actual
                                DateTime now = DateTime.now();

                                // Calcular el límite de 3 días desde la fecha actual
                                DateTime maxDate =
                                    now.add(const Duration(days: 4));

                                // Verificar si la fecha seleccionada está dentro de los próximos 3 días
                                if (date.isAfter(maxDate)) {
                                  SnackBarService.instance.showSnackBar(
                                    "Por favor selecciona una fecha dentro de los próximos 4 días",
                                    false,
                                  );
                                } else if (startDateTime.isBefore(now)) {
                                  // Verificar si la hora de inicio es antes de la hora actual
                                  SnackBarService.instance.showSnackBar(
                                    "Por favor selecciona una hora futura",
                                    false,
                                  );
                                } else if (date.isAfter(dateNow
                                    .subtract(const Duration(days: 1)))) {
                                  // Guardar los datos si la fecha y hora son válidos
                                  PreferencesProvider.instance
                                      .setStartTime(startTime!);
                                  PreferencesProvider.instance
                                      .setEndTime(endTime!);
                                  PreferencesProvider.instance.setDate(date);

                                  NavigationService.instance.navigatePushName(
                                    SpecificPoiSelectionScreen.routeName,
                                  );
                                } else {
                                  SnackBarService.instance.showSnackBar(
                                    "Por favor, selecciona una fecha correcta",
                                    false,
                                  );
                                }

                                print(
                                    'Hora fin ${PreferencesProvider.instance.getEndTime()}');
                                print(
                                    'Hora inicio ${PreferencesProvider.instance.getStartTIme()}');
                                print(
                                    'Fecha recorrido ${PreferencesProvider.instance.getDate()}');
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.white,
                              backgroundColor: Colors.purple,
                            ),
                            child: const Text('Confirmar'),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget selectTime(BuildContext context, String type) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            ElevatedButton(
              onPressed: () {
                selectTimePicker(context, type);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colores.azul,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Icon(
                Icons.timer,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: TextField(
                enabled: false,
                //controller: controller,
                decoration: InputDecoration(
                  hintText: type == 'start'
                      ? startTime == null
                          ? 'Te recomiendo: 8:00 am'
                          : 'Inicio: ${startTime!.format(context)}'
                      : endTime == null
                          ? 'Te recomiendo: 8:00 pm'
                          : 'Fin: ${endTime!.format(context)}',
                  border: InputBorder.none,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget datePiker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(bottom: 10),
          child: Text('Fecha:',
              style: TextStyle(
                fontSize: 23,
                color: Colores.azul,
              )),
        ),
        EasyDateTimeLine(
          onDateChange: (selectedDate) {
            if (!selectedDate
                .isAfter(dateNow.subtract(const Duration(days: 1)))) {
              SnackBarService.instance.showSnackBar(
                  "Por favor, seleccione una fecha futura", false);
            }
            date = selectedDate;
          },
          locale: "es_ES",
          initialDate: dateNow,
          headerProps: const EasyHeaderProps(
            monthPickerType: MonthPickerType.dropDown,
            dateFormatter: DateFormatter.fullDateDMonthAsStrY(),
          ),
          dayProps: const EasyDayProps(
            dayStructure: DayStructure.dayStrDayNum,
            activeDayStyle: DayStyle(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(
                    Radius.circular(8),
                  ),
                  gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colores.azul,
                        Colores.morado,
                      ])),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> selectTimePicker(BuildContext context, String type) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: type == 'start'
          ? const TimeOfDay(hour: 8, minute: 0)
          : const TimeOfDay(hour: 20, minute: 0),
      initialEntryMode: TimePickerEntryMode.input,
    );

    if (picked != null && picked != startTime) {
      int roundedMinute;
      int newHour = picked.hour;

      // Lógica para redondear los minutos
      if (picked.minute >= 45) {
        // Si los minutos son >= 45, se sube la hora a la siguiente
        roundedMinute = 0;
        newHour = (picked.hour + 1) %
            24; // Incrementa la hora y asegura que no se pase de 23
      } else if (picked.minute >= 30) {
        // Si los minutos son >= 30 pero < 45, se ajusta a x:30
        roundedMinute = 30;
      } else if (picked.minute >= 15) {
        // Si los minutos son >= 15 pero < 30, se ajusta a x:30
        roundedMinute = 30;
      } else {
        // Si los minutos son < 15, se ajusta a x:00
        roundedMinute = 0;
      }

      TimeOfDay roundedTime = TimeOfDay(hour: newHour, minute: roundedMinute);

      setState(() {
        if (type == 'start') {
          startTime = roundedTime;
        } else {
          endTime = roundedTime;
        }
      });

      // Validación: verifica que la hora de inicio no sea superior a la de fin
      if (startTime != null && endTime != null) {
        final int startMinutes = startTime!.hour * 60 + startTime!.minute;
        final int endMinutes = endTime!.hour * 60 + endTime!.minute;

        if (startMinutes > endMinutes) {
          SnackBarService.instance.showSnackBar(
            "La hora de inicio no puede ser superior a la hora de fin",
            false,
          );

          // Reinicia la hora actualizada para evitar inconsistencias
          if (type == 'start') {
            startTime = null;
          } else {
            endTime = null;
          }
        }

        // Validación: verifica que haya al menos 6 horas de diferencia
        if ((endMinutes - startMinutes) < 360) {
          SnackBarService.instance.showSnackBar(
            "Debe haber al menos 6 horas de diferencia entre inicio y fin",
            false,
          );

          // Reinicia la hora actualizada para evitar inconsistencias
          if (type == 'start') {
            startTime = null;
          } else {
            endTime = null;
          }
          return;
        }
      }
    }
  }
}
