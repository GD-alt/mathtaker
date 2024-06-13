import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:flutter/gestures.dart';
import 'package:logging/logging.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher_string.dart';

void main() async{
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((record) {
    stderr.write('${record.level.name}: ${record.time}: ${record.message}');
  });

  runApp(const MyApp());
}

int randInInterval(int min, int max) {
  var random = Random();
  return random.nextInt(max - min) + min;
}

final logger = Logger('main');

final themes = {
  'light': ThemeData(
    colorScheme: ColorScheme(
      primary: Colors.blue,
      secondary: Colors.blue.shade200,
      surface: Colors.white,
      error: Colors.red,
      onPrimary: Colors.white,
      onSecondary: Colors.black,
      onSurface: Colors.black,
      onError: Colors.white,
      brightness: Brightness.light,
    ),
    useMaterial3: true,
  ),
  'dark': ThemeData(
    colorScheme: ColorScheme(
      primary: Colors.blue,
      secondary: Colors.blue.shade600,
      surface: Colors.black,
      error: Colors.red,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: Colors.white,
      onError: Colors.white,
      brightness: Brightness.dark,
    ),
    useMaterial3: true,
  ),
};


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mathtaker',
      theme: themes['light'],
      darkTheme: themes['dark'],
      themeMode: ThemeMode.system,
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  @override
  State<HomePage> createState() => _HomePageState();
}

enum Difficulty { easy, medium, hard }


class DifficultySelector extends StatefulWidget {
  final Difficulty selectedDifficulty;
  final ValueChanged<Set<Difficulty>> onDifficultyChanged;

  const DifficultySelector(
    {
      super.key,
      required this.onDifficultyChanged,
      required this.selectedDifficulty,
    }
  );

  @override
  State<DifficultySelector> createState() => _DifficultySelectorState();
}

class _DifficultySelectorState extends State<DifficultySelector> {
  @override
  Widget build(BuildContext context) {
    return SegmentedButton(
      segments: const [
        ButtonSegment<Difficulty>(
          value: Difficulty.easy,
          label: Text('Easy'),
        ),
        ButtonSegment<Difficulty>(
          value: Difficulty.medium,
          label: Text('Med'),
        ),
        ButtonSegment<Difficulty>(
          value: Difficulty.hard,
          label: Text('Hard'),
        ),
      ],
      selected: <Difficulty>{widget.selectedDifficulty},
      onSelectionChanged: widget.onDifficultyChanged,
      style: const ButtonStyle(
        visualDensity: VisualDensity.compact,
      )
    );
  }
}

class TimeSelector extends StatefulWidget {
  final int selectedTime;
  final ValueChanged<Set<int>> onTimeChanged;

  const TimeSelector(
      {
        super.key,
        required this.onTimeChanged,
        required this.selectedTime,
      }
      );

  @override
  State<TimeSelector> createState() => _TimeSelectorState();
}

class _TimeSelectorState extends State<TimeSelector> {
  @override
  Widget build(BuildContext context) {
    return SegmentedButton(
        segments: const [
          ButtonSegment<int>(
            value: 40,
            icon: Icon(Icons.skip_previous),
          ),
          ButtonSegment<int>(
            value: 30,
            icon: Icon(Icons.fast_rewind),
          ),
          ButtonSegment<int>(
            value: 20,
            icon: Icon(Icons.play_arrow),
          ),
          ButtonSegment<int>(
            value: 10,
            icon: Icon(Icons.fast_forward),
          ),
          ButtonSegment<int>(
            value: 5,
            icon: Icon(Icons.skip_next),
          ),
        ],
        selected: <int>{widget.selectedTime},
        onSelectionChanged: widget.onTimeChanged,
        style: const ButtonStyle(
          visualDensity: VisualDensity.compact,
        )
    );
  }
}

class GameLengthSelector extends StatefulWidget {
  final int selectedLength;
  final ValueChanged<Set<int>> onLengthChanged;

  const GameLengthSelector(
      {
        super.key,
        required this.onLengthChanged,
        required this.selectedLength,
      }
      );

  @override
  State<GameLengthSelector> createState() => _GameLengthSelectorState();
}

class _GameLengthSelectorState extends State<GameLengthSelector> {
  @override
  Widget build(BuildContext context) {
    return SegmentedButton(
        segments: const [
          ButtonSegment<int>(
            value: 20,
            label: Text('2'),
          ),
          ButtonSegment<int>(
            value: 40,
            label: Text('4'),
          ),
          ButtonSegment<int>(
            value: 50,
            label: Text('5'),
          ),
          ButtonSegment<int>(
            value: 60,
            label: Text('6'),
          ),
          ButtonSegment<int>(
            value: 80,
            label: Text('8'),
          ),
        ],
        selected: <int>{widget.selectedLength},
        onSelectionChanged: widget.onLengthChanged,
        style: const ButtonStyle(
          visualDensity: VisualDensity.compact,
        )
    );
  }
}

const margins = {
  'topOnly': EdgeInsets.only(top: 20),
  'botOnly': EdgeInsets.only(bottom: 20),
  'topOnlyL': EdgeInsets.only(top: 50),
  'botOnlyL': EdgeInsets.only(bottom: 50),
  'topLeftRight': EdgeInsets.only(top: 5, left: 20, right: 20),
  'TLR20': EdgeInsets.only(top: 20, left: 20, right: 20),
  'leftRight': EdgeInsets.only(left: 20, right: 20),
};


class _HomePageState extends State<HomePage> {
  Difficulty _selectedDifficulty = Difficulty.easy;
  bool _useAddition = true;
  bool _useSubtraction = true;
  bool _useMultiplication = true;
  bool _useDivision = true;
  int _selectedTime = 30;
  int _selectedLength = 20;

  void _handleDifficultyChanged(Set<Difficulty> difficulty) {
    setState(() {
      _selectedDifficulty = difficulty.first;
    });
  }

  void _handleTimeChanged(Set<int> time) {
    setState(() {
      _selectedTime = time.first;
    });
  }

  void _handleLengthChanged(Set<int> length) {
    setState(() {
      _selectedLength = length.first;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // Header with name `Mathtaker`
            Text(
              'Mathtaker',
              style: Theme.of(context).textTheme.headlineMedium,
              textAlign: TextAlign.center,
            ),

            // Subtitle with name `A simple math quiz app`
            Text(
              'A simple math quiz app',
              style: Theme.of(context).textTheme.titleSmall,
              textAlign: TextAlign.center,
            ),

            // Round button with `play` icon
            Container(
              margin: margins['topOnly'],
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    margin: margins['leftRight'],
                    child: FloatingActionButton(
                      onPressed: () => {
                        // If none of the operations are selected, show an alert
                        if (!_useAddition && !_useSubtraction && !_useMultiplication && !_useDivision) {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: const Text('No operations selected'),
                                content: const Text('Please select at least one operation to continue.'),
                                actions: <Widget>[
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: const Text('OK'),
                                  ),
                                ],
                              );
                            },
                          ),
                        } else

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => QuizPage(
                              useAddition: _useAddition,
                              useSubtraction: _useSubtraction,
                              useMultiplication: _useMultiplication,
                              useDivision: _useDivision,
                              selectedDifficulty: _selectedDifficulty,
                              time: _selectedTime,
                              length: _selectedLength,
                            ),
                          ),
                        ),
                      },
                      tooltip: 'Start',
                      shape: const CircleBorder(),
                      child: const Icon(Icons.play_arrow),
                    ),
                  ),

                  Container(
                    margin: margins['leftRight'],
                    child: FloatingActionButton(
                      shape: const CircleBorder(),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text('About Mathtaker'),
                              content: RichText(
                                  text: TextSpan(
                                    children: [
                                      TextSpan(
                                        text: 'Mathtaker is a simple math quiz app. Select the operations, difficulty, time, and number of questions for the quiz. Press the play button to start the quiz. Be fast and complete difficult tasks to collect more points. Good luck!\n\nView the source code on GitHub: ',
                                        style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                                      ),
                                      TextSpan(
                                        text: 'https://github.com/GD-alt/mathtaker',
                                        style: TextStyle(color: Theme.of(context).colorScheme.primary, decoration: TextDecoration.underline),
                                        recognizer: TapGestureRecognizer()
                                          ..onTap = () {
                                            Future.wait([launchUrlString('https://github.com/GD-alt/mathtaker')]);
                                          },
                                      ),
                                    ]
                                  ),
                            ),
                              actions: <Widget>[
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: const Text('Close'),
                                ),
                              ],
                            );
                          },
                        );
                      },
                      heroTag: 'info',
                      child: const Icon(Icons.info),
                    ),
                  ),
                ],
              )
            ),

            // SegmentedButton with `Easy`, `Medium`, `Hard` options
            Container(
              margin: margins['TLR20'],
              child: DifficultySelector(
                selectedDifficulty: _selectedDifficulty,
                onDifficultyChanged: _handleDifficultyChanged,
              ),
            ),

            Container(
              margin: margins['topOnly'],
              child: Text(
                'Select game speed:',
                style: Theme.of(context).textTheme.titleSmall,
                textAlign: TextAlign.center,
              ),
            ),

            Container(
              margin: margins['TLR20'],
              child: TimeSelector(
                selectedTime: _selectedTime,
                onTimeChanged: _handleTimeChanged,
              ),
            ),

            Container(
              margin: margins['topOnly'],
              child: Text(
                'Select number of questions for the quiz (x10):',
                style: Theme.of(context).textTheme.titleSmall,
                textAlign: TextAlign.center,
              ),
            ),

            Container(
              margin: margins['TLR20'],
              child: GameLengthSelector(
                selectedLength: _selectedLength,
                onLengthChanged: _handleLengthChanged,
              ),
            ),

            Container(
              margin: margins['topOnlyL'],
              child: Text(
                'Select operations to include in the quiz:',
                style: Theme.of(context).textTheme.titleSmall,
                textAlign: TextAlign.center,
              ),
            ),

            // Checkbox with `Addition` option
            Container(
              margin: margins['topLeftRight'],
              child: CheckboxListTile(
                title: const Text('Addition'),
                value: _useAddition,
                onChanged: (bool? value) {
                  setState(() {
                    _useAddition = value!;
                  });
                },
              ),
            ),

            // Checkbox with `Subtraction` option
            Container(
              margin: margins['topLeftRight'],
              child: CheckboxListTile(
                title: const Text('Subtraction'),
                value: _useSubtraction,
                onChanged: (bool? value) {
                  setState(() {
                    _useSubtraction = value!;
                  });
                },
              ),
            ),

            // Checkbox with `Multiplication` option
            Container(
              margin: margins['topLeftRight'],
              child: CheckboxListTile(
                title: const Text('Multiplication'),
                value: _useMultiplication,
                onChanged: (bool? value) {
                  setState(() {
                    _useMultiplication = value!;
                  });
                },
              ),
            ),

            // Checkbox with `Division` option
            Container(
              margin: margins['topLeftRight'],
              child: CheckboxListTile(
                title: const Text('Division'),
                value: _useDivision,
                onChanged: (bool? value) {
                  setState(() {
                    _useDivision = value!;
                  });
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}


class Problem {
  final int? param1;
  final int? param2;
  final int? answer;
  final String operator;

  Problem({this.param1, required this.operator, this.param2, this.answer});
}


class QuizPage extends StatefulWidget {
  final bool useAddition;
  final bool useSubtraction;
  final bool useMultiplication;
  final bool useDivision;
  final Difficulty selectedDifficulty;
  final List<Problem> problems = [];
  final int time;
  final int length;

  QuizPage({
    super.key,
    required this.useAddition,
    required this.useSubtraction,
    required this.useMultiplication,
    required this.useDivision,
    required this.selectedDifficulty,
    required this.time,
    required this.length,
  });

  void generateProblems() {
    problems.clear();

    var operationsBool = [
      useAddition,
      useSubtraction,
      useMultiplication,
      useDivision
    ];
    var operations = [];

    for (var i = 0; i < operationsBool.length; i++) {
      if (operationsBool[i]) {
        switch (i) {
          case 0:
            operations.add('+');
            break;
          case 1:
            operations.add('–');
            break;
          case 2:
            operations.add('×');
            break;
          case 3:
            operations.add('÷');
            break;
        }
      }
    }

    // Choose random operation
    var random = Random();

    for (var i = 0; i < length; i++) {
      var operation = operations[random.nextInt(operations.length)];

      switch (operation) {
        case '+':
          int param1;
          int param2;

          switch (selectedDifficulty) {
            case Difficulty.easy:
              param1 = randInInterval(0, 100);
              param2 = randInInterval(0, 100);
              break;
            case Difficulty.medium:
              param1 = randInInterval(0, 750);
              param2 = randInInterval(0, 750);
              break;
            case Difficulty.hard:
              param1 = randInInterval(0, 7000);
              param2 = randInInterval(0, 7000);
              break;
          }

          // If not unique, generate new params
          while (problems.any((problem) => problem.param1 == param1 && problem.param2 == param2)) {
            switch (selectedDifficulty) {
              case Difficulty.easy:
                param1 = randInInterval(0, 100);
                param2 = randInInterval(0, 100);
                break;
              case Difficulty.medium:
                param1 = randInInterval(0, 750);
                param2 = randInInterval(0, 750);
                break;
              case Difficulty.hard:
                param1 = randInInterval(0, 7000);
                param2 = randInInterval(0, 7000);
                break;
            }
          }

          problems.add(Problem(
            param1: param1,
            operator: operation,
            param2: param2,
            answer: param1 + param2,
          ));
          break;

        case '–':
          int param1;
          int param2;

          switch (selectedDifficulty) {
            case Difficulty.easy:
              param1 = randInInterval(0, 100);
              param2 = randInInterval(0, 100);
              break;
            case Difficulty.medium:
              param1 = randInInterval(0, 750);
              param2 = randInInterval(0, 750);
              break;
            case Difficulty.hard:
              param1 = randInInterval(0, 7000);
              param2 = randInInterval(0, 7000);
              break;
          }

          // If not unique, generate new params
          while (problems.any((problem) => problem.param1 == param1 && problem.param2 == param2)) {
            switch (selectedDifficulty) {
              case Difficulty.easy:
                param1 = randInInterval(0, 100);
                param2 = randInInterval(0, 100);
                break;
              case Difficulty.medium:
                param1 = randInInterval(0, 750);
                param2 = randInInterval(0, 750);
                break;
              case Difficulty.hard:
                param1 = randInInterval(0, 7000);
                param2 = randInInterval(0, 7000);
                break;
            }
          }

          problems.add(Problem(
            param1: param1,
            operator: operation,
            param2: param2,
            answer: param1 - param2,
          ));
          break;

        case '×':
          int param1;
          int param2;

          switch (selectedDifficulty) {
            case Difficulty.easy:
              param1 = randInInterval(0, 10);
              param2 = randInInterval(0, 10);
              break;
            case Difficulty.medium:
              param1 = randInInterval(0, 45);
              param2 = randInInterval(0, 45);
              break;
            case Difficulty.hard:
              param1 = randInInterval(0, 90);
              param2 = randInInterval(0, 90);
              break;
          }

          // If not unique, generate new params
          while (problems.any((problem) => problem.param1 == param1 && problem.param2 == param2)) {
            switch (selectedDifficulty) {
              case Difficulty.easy:
                param1 = randInInterval(0, 10);
                param2 = randInInterval(0, 10);
                break;
              case Difficulty.medium:
                param1 = randInInterval(0, 45);
                param2 = randInInterval(0, 45);
                break;
              case Difficulty.hard:
                param1 = randInInterval(0, 90);
                param2 = randInInterval(0, 90);
                break;
            }
          }

          problems.add(Problem(
            param1: param1,
            operator: operation,
            param2: param2,
            answer: param1 * param2,
          ));
          break;

        case '÷':
          int answer;
          int param2;

          switch (selectedDifficulty) {
            case Difficulty.easy:
              answer = randInInterval(0, 10);
              param2 = randInInterval(1, 10);
              break;
            case Difficulty.medium:
              answer = randInInterval(0, 40);
              param2 = randInInterval(1, 40);
              break;
            case Difficulty.hard:
              answer = randInInterval(0, 85);
              param2 = randInInterval(1, 85);
              break;
          }

          // If not unique, generate new params
          while (problems.any((problem) => problem.param2 == param2 && problem.answer == answer)) {
            switch (selectedDifficulty) {
              case Difficulty.easy:
                answer = randInInterval(0, 10);
                param2 = randInInterval(1, 10);
                break;
              case Difficulty.medium:
                answer = randInInterval(0, 40);
                param2 = randInInterval(1, 40);
                break;
              case Difficulty.hard:
                answer = randInInterval(0, 85);
                param2 = randInInterval(1, 85);
                break;
            }
          }

          var param1 = answer * param2;
          problems.add(Problem(
            param1: param1,
            operator: operation,
            param2: param2,
            answer: answer,
          ));
      }
    }
  }

  String problemsToString() {
    var problemsString = '';

    for (var i = 0; i < problems.length; i++) {
      problemsString += '${problems[i].param1} ${problems[i].operator} ${problems[i].param2} = ?\n';
    }

    return problemsString;
  }

  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  @override
  void initState() {
    super.initState();
    widget.generateProblems();
    timerLeft = widget.time;
  }

  var _started = false;
  var _inputAvaliable = false;
  var _buttonIcon = Icons.play_arrow;
  final TextEditingController _controller = TextEditingController();
  var problemIndex = 0;
  var _score = 0;
  late int timerLeft;
  Timer? t;
  var totalTime = 0;
  var problemText = 'X + Y = …';
  var inputText = '';
  var subtitleText = 'Press the button below to start the quiz.';
  var timerText = 'Timer will be here.';

  void startTimer() {
    t = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (timerLeft == 0) {
          timerLeft = widget.time;
          next();
        } else {
          timerText = 'Time left: $timerLeft';
          timerLeft--;
        }
      });
    });
  }

  void next() {
    if (!_started) {
      setState(() {
        _started = true;
        _inputAvaliable = true;
        _buttonIcon = Icons.arrow_forward;
        subtitleText = 'Answer the question above and press the button below.';
        _controller.clear();
        timerText = 'Time left: $timerLeft';
        startTimer();
        problemText = '${widget.problems[problemIndex].param1} ${widget.problems[problemIndex].operator} ${widget.problems[problemIndex].param2} = …';
      });
    }

    else if (problemIndex == widget.problems.length - 1) {
      if (t != null) {
        t!.cancel();
      }

      var operationBonus = 0;

      switch (widget.problems[problemIndex].operator) {
        case '+':
          operationBonus = 0;
          break;
        case '–':
          operationBonus = 0;
          break;
        case '×':
          operationBonus = 1;
          break;
        case '÷':
          operationBonus = 2;
          break;
      }

      if (inputText == widget.problems[problemIndex].answer.toString()) {
        switch (widget.selectedDifficulty) {
          case Difficulty.easy:
            setState(() {
              _score += 1 + operationBonus;
            });
            break;
          case Difficulty.medium:
            setState(() {
              _score += 2 + operationBonus;
            });
            break;
          case Difficulty.hard:
            setState(() {
              _score += 3 + operationBonus;
            });
            break;
        }

          totalTime += widget.time - timerLeft;
      }

      setState(() {
        _buttonIcon = Icons.done;
        _inputAvaliable = false;
      });

      var mediumTime = totalTime ~/ widget.length;
      var bonus = 0;

      if (mediumTime <= 5) {
        bonus = _score;
        _score += bonus;
      }

      else if (mediumTime <= 10) {
        bonus = _score ~/ 2;
        _score += bonus;
      }

      // Show the final score
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Quiz finished!'),
            content: Text('Your final score: $_score (+$bonus for average time). Thanks for playing!'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    }

    else {
      totalTime += widget.time - timerLeft;
      timerLeft = widget.time;

      if (inputText == '') {
        setState(() {
          subtitleText = 'Skipped! The answer was ${widget.problems[problemIndex].answer}. Your current score: $_score';
        });
      }

      else if (inputText == widget.problems[problemIndex].answer.toString()) {
        var operationBonus = 0;

        switch (widget.problems[problemIndex].operator) {
          case '+':
            operationBonus = 0;
            break;
          case '–':
            operationBonus = 0;
            break;
          case '×':
            operationBonus = 1;
            break;
          case '÷':
            operationBonus = 2;
            break;
        }

        if (inputText == widget.problems[problemIndex].answer.toString()) {
          switch (widget.selectedDifficulty) {
            case Difficulty.easy:
              setState(() {
                _score += 1 + operationBonus;
              });
              break;
            case Difficulty.medium:
              setState(() {
                _score += 2 + operationBonus;
              });
              break;
            case Difficulty.hard:
              setState(() {
                _score += 3 + operationBonus;
              });
              break;
          }

            totalTime += widget.time - timerLeft;
            subtitleText = 'Correct! Your current score: $_score';
        }
      }

      else {
        setState(() {
          subtitleText = 'Incorrect! The answer was ${widget.problems[problemIndex].answer}. Your current score: $_score';
        });
      }

      if (problemIndex != widget.problems.length - 1) {
        setState(() {
          problemIndex++;
        });
      }

      setState(() {
        problemText = '${widget.problems[problemIndex].param1} ${widget.problems[problemIndex].operator} ${widget.problems[problemIndex].param2} = …';
      });

      _controller.clear();

      if (problemIndex == widget.problems.length - 1) {
        setState(() {
          _buttonIcon = Icons.done;
        });

        if (t != null) {
          t!.cancel();
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: problemIndex == 0,
      child: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Align(
                alignment: Alignment.topCenter,
                child: Container(
                  margin: margins['botOnly'],
                  child: Text(
                    'Your current score: $_score, current problem: ${problemIndex + 1}',
                    style: Theme.of(context).textTheme.titleSmall,
                    textAlign: TextAlign.center,
                  ),
                ),
              ),

              Align(
                alignment: Alignment.topCenter,
                child: Container(
                  margin: margins['botOnlyL'],
                  child: Text(
                    timerText,
                    style: Theme.of(context).textTheme.titleSmall,
                    textAlign: TextAlign.center,
                  ),
                ),
              ),

              Container(
                margin: margins['botOnly'],
                // Text with problems
                child: Text(
                  problemText,
                  style: Theme.of(context).textTheme.headlineLarge,
                  textAlign: TextAlign.center,
                ),
              ),

              // Input field for the answer
              Container(
                margin: margins['topLeftRight'],
                child: TextField(
                  enabled: _inputAvaliable,
                  controller: _controller,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Enter your answer',
                  ),
                  keyboardType: TextInputType.number,
                  style: Theme.of(context).textTheme.titleSmall,
                  onChanged: (text) {
                    setState(() {
                      inputText = text;
                    });
                  },
                ),
              ),

              Container(
                margin: margins['topOnly'],
                child: Text(
                  subtitleText,
                  style: Theme.of(context).textTheme.titleSmall,
                  textAlign: TextAlign.center,
                ),
              ),

              // Round button with `play` icon
              Container(
                margin: margins['topOnly'],
                child: FloatingActionButton(
                  onPressed: next,
                  tooltip: 'Next',
                  child: Icon(_buttonIcon),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
