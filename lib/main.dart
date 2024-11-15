import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() {
  initializeDateFormatting('ru'); // Инициализация локализации
  runApp(CalendarApp());
}

class CalendarApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Calendar',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: CalendarScreen(),
    );
  }
}

class CalendarScreen extends StatefulWidget {
  @override
  _CalendarScreenState createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _selectedDate = DateTime.now();
  DateTime _currentDate = DateTime.now();
  Set<DateTime> _workoutDays = {}; // Множество для хранения дат с тренировками

  // Функция для перехода на предыдущий месяц
  void _previousMonth() {
    setState(() {
      _selectedDate = DateTime(_selectedDate.year, _selectedDate.month - 1);
    });
  }

  // Функция для перехода на следующий месяц
  void _nextMonth() {
    setState(() {
      _selectedDate = DateTime(_selectedDate.year, _selectedDate.month + 1);
    });
  }

  // Функция для уменьшения года
  void _previousYear() {
    setState(() {
      _selectedDate = DateTime(_selectedDate.year - 1, _selectedDate.month);
    });
  }

  // Функция для увеличения года
  void _nextYear() {
    setState(() {
      _selectedDate = DateTime(_selectedDate.year + 1, _selectedDate.month);
    });
  }

  // Функция для возврата к текущему месяцу
  void _resetToCurrentMonth() {
    setState(() {
      _selectedDate = _currentDate;
    });
  }

  // Получение количества дней в текущем месяце
  int _daysInMonth(DateTime date) {
    return DateTime(date.year, date.month + 1, 0).day;
  }

  // Функция для переключения состояния тренировки
  void _toggleWorkout(DateTime date) {
    setState(() {
      if (_workoutDays.contains(date)) {
        _workoutDays.remove(date); // Удалить тренировку, если уже есть
      } else {
        _workoutDays.add(date); // Добавить тренировку, если её ещё нет
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Календарь")),
      body: Column(
        children: [
          // Заголовок с указанием месяца и года
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: Icon(Icons.arrow_back),
                  onPressed: _previousMonth,
                ),
                Column(
                  children: [
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(Icons.arrow_left),
                          onPressed: _previousYear,
                        ),
                        Text(
                          '${_selectedDate.year}',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        IconButton(
                          icon: Icon(Icons.arrow_right),
                          onPressed: _nextYear,
                        ),
                      ],
                    ),
                    Text(
                      DateFormat.MMMM('ru').format(_selectedDate), // Название месяца на русском
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                IconButton(
                  icon: Icon(Icons.arrow_forward),
                  onPressed: _nextMonth,
                ),
              ],
            ),
          ),
          // Сетка дней недели
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: ['Пн', 'Вт', 'Ср', 'Чт', 'Пт', 'Сб', 'Вс']
                  .map((day) => Expanded(
                        child: Center(
                          child: Text(
                            day,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ))
                  .toList(),
            ),
          ),
          // Сетка для дней в месяце
          Expanded(
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7, // 7 дней в неделю
              ),
              itemCount: _daysInMonth(_selectedDate) +
                  DateTime(_selectedDate.year, _selectedDate.month, 1).weekday - 1,
              itemBuilder: (context, index) {
                // Начальные пустые ячейки для смещения дней
                if (index < DateTime(_selectedDate.year, _selectedDate.month, 1).weekday - 1) {
                  return Container();
                }
                // Реальный день месяца
                final day = index - DateTime(_selectedDate.year, _selectedDate.month, 1).weekday + 2;
                final date = DateTime(_selectedDate.year, _selectedDate.month, day);
                final isToday = date.day == _currentDate.day &&
                    date.month == _currentDate.month &&
                    date.year == _currentDate.year;
                final isWeekend = date.weekday == DateTime.saturday || date.weekday == DateTime.sunday;
                final isWorkoutDay = _workoutDays.contains(date);

                // Установка стиля ячейки в зависимости от условий
                BoxDecoration decoration;
                if (isToday && isWorkoutDay) {
                  decoration = BoxDecoration(
                    color: Colors.blue, // Синий фон для текущего дня
                    border: Border.all(color: Colors.green, width: 2), // Зеленая рамка для тренировки
                    borderRadius: BorderRadius.circular(8),
                  );
                } else if (isToday) {
                  decoration = BoxDecoration(
                    color: Colors.blue, // Синий фон для текущего дня
                    borderRadius: BorderRadius.circular(8),
                  );
                } else if (isWorkoutDay) {
                  decoration = BoxDecoration(
                    color: Colors.green, // Зеленый фон для дня с тренировкой
                    borderRadius: BorderRadius.circular(8),
                  );
                } else if (isWeekend) {
                  decoration = BoxDecoration(
                    color: Colors.grey.shade200, // Серый фон для выходных
                    borderRadius: BorderRadius.circular(8),
                  );
                } else {
                  decoration = BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                  );
                }

                return GestureDetector(
                  onTap: () => _toggleWorkout(date),
                  child: Container(
                    alignment: Alignment.center,
                    decoration: decoration,
                    child: Text(
                      '$day',
                      style: TextStyle(
                        color: isToday
                            ? Colors.white
                            : isWeekend
                                ? Colors.red
                                : Colors.black,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          // Кнопка возврата к текущему месяцу
          if (_selectedDate.month != _currentDate.month || _selectedDate.year != _currentDate.year)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                onPressed: _resetToCurrentMonth,
                child: Text("Вернуться к текущему месяцу"),
              ),
            ),
        ],
      ),
    );
  }
}
