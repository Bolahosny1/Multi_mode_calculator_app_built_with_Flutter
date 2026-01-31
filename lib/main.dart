import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:powers/powers.dart';
import 'package:fraction/fraction.dart';

void main() {
  runApp(const MyCalculatorApp());
}

class MyCalculatorApp extends StatelessWidget {
  const MyCalculatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const CalculatorPage(),
    );
  }
}

class CalculatorPage extends StatefulWidget {
  const CalculatorPage({super.key});

  @override
  State<CalculatorPage> createState() => _CalculatorPageState();
}

class _CalculatorPageState extends State<CalculatorPage> {
  int currentBase = 10;
  String activeProgrammerKey = '';
  String display = '0';
  double? firstNum;
  String operation = '';
  bool shouldResetDisplay = false;
  String mode = 'basic';

  void numPress(String num) {
    setState(() {
      if (display == '0' || shouldResetDisplay) {
        display = num;
        shouldResetDisplay = false;
      } else {
        display += num;
      }
    });
  }

  void opPress(String op) {
    setState(() {
      if (display.isFraction) {
        display = Fraction.fromString(display).toDouble().toString();
      }
      if (display.isMixedFraction) {
        display =
            Fraction.fromMixedFraction(
              display.toMixedFraction(),
            ).toDouble().toString();
      }
      firstNum = double.tryParse(display);
      operation = op;
      shouldResetDisplay = true;
    });
  }

  void calculate() {
    double? secondNum = double.tryParse(display);
    double result = 0;

    if (firstNum == null || secondNum == null) return;

    if (operation == '+') {
      result = firstNum! + secondNum;
    } else if (operation == '-') {
      result = firstNum! - secondNum;
    } else if (operation == '×') {
      result = firstNum! * secondNum;
    } else if (operation == '÷') {
      if (secondNum == 0) {
        setState(() {
          display = 'Error';
          shouldResetDisplay = true;
        });
        return;
      }
      result = firstNum! / secondNum;
    } else if (operation == '^') {
      result = math.pow(firstNum!, secondNum).toDouble();
    } else if (operation == 'logᵧx') {
      result = math.log(firstNum!) / math.log(secondNum);
    }

    setState(() {
      if (result.isValidInteger) {
        display = result.toStringAsFixed(0);
      } else {
        display = result.toStringAsFixed(2);
      }
      shouldResetDisplay = true;
      operation = '';
    });
  }

  void clear() {
    setState(() {
      display = '0';
      firstNum = null;
      operation = '';
      shouldResetDisplay = false;
    });
  }

  void delete() {
    setState(() {
      if (display.length > 1) {
        display = display.substring(0, display.length - 1);
      } else {
        display = '0';
      }
    });
  }

  void decimal() {
    setState(() {
      if (!display.contains('.')) {
        display += '.';
      }
    });
  }

  void toggleSign() {
    setState(() {
      if (display.startsWith('-')) {
        display = display.substring(1);
      } else if (display != '0') {
        display = '-$display';
      }
    });
  }

  void fraction() {
    setState(() {
      if (display.isFraction && !display.isMixedFraction) {
        //from 3/2 to 1.5
        display = Fraction.fromString(display).toDouble().toString();
      } else if (!display.isFraction && !display.isMixedFraction) {
        //from 1.5 to 1 1/2
        display =
            MixedFraction.fromDouble(double.tryParse(display)!).toString();
      } else {
        //from 1 1/2 to 3/2
        var temp =
        Fraction.fromMixedFraction(display.toMixedFraction()).toDouble();
        display = Fraction.fromDouble(temp, precision: 1e-5).toString();
      }
    });
  }

  void sciFunc(String func) {
    double? num = double.tryParse(display);
    if (num == null) return;

    double result = 0;
    if (func == 'sin') {
      result = math.sin(num * math.pi / 180);
    } else if (func == 'cos') {
      result = math.cos(num * math.pi / 180);
    } else if (func == 'tan') {
      result = math.tan(num * math.pi / 180);
    } else if (func == 'csc') {
      result = 1 / math.sin(num * math.pi / 180);
    } else if (func == 'sec') {
      result = 1 / math.cos(num * math.pi / 180);
    } else if (func == 'cot') {
      result = 1 / math.tan(num * math.pi / 180);
    } else if (func == 'log') {
      result = math.log(num) / math.log(10);
    } else if (func == 'ln') {
      result = math.log(num);
    } else if (func == '√') {
      result = math.sqrt(num);
    } else if (func == '√³') {
      result = num.root(3);
    } else if (func == 'x²') {
      result = math.pow(num, 2).toDouble();
    } else if (func == 'x³') {
      result = math.pow(num, 3).toDouble();
    } else if (func == 'x¯¹') {
      result = 1 / num;
    } else if (func == '2ⁿ') {
      result = math.pow(2, num).toDouble();
    }

    setState(() {
      display =
      result.isNaN || result.isInfinite
          ? 'Error'
          : result.isValidInteger
          ? result.toStringAsFixed(0)
          : result.toStringAsFixed(5);
      shouldResetDisplay = true;
    });
  }

  void modeChange(String newMode) {
    setState(() {
      mode = newMode;
      clear();
    });
  }

  Widget buildButton(
      String text,
      VoidCallback onHold,
      VoidCallback onPressed, {
        Color? color,
        Color textColor = Colors.black,
      }) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(5.0),
        child: ElevatedButton(
          onPressed: onPressed,
          onLongPress: onHold,
          style: ElevatedButton.styleFrom(
            backgroundColor: color ?? Colors.grey[200],
            padding: const EdgeInsets.all(18),
          ),
          child: Text(text, style: TextStyle(fontSize: 20, color: textColor)),
        ),
      ),
    );
  }

  Widget buildScientificPad() {
    return Column(
      children: [
        Row(
          children: [
            buildButton('sin', () {}, () => sciFunc('sin')),
            buildButton('cos', () {}, () => sciFunc('cos')),
            buildButton('tan', () {}, () => sciFunc('tan')),
            buildButton('√²', () {}, () => sciFunc('√')),
          ],
        ),
        Row(
          children: [
            buildButton('csc', () {}, () => sciFunc('csc')),
            buildButton('sec', () {}, () => sciFunc('sec')),
            buildButton('cot', () {}, () => sciFunc('cot')),
            buildButton('√³', () {}, () => sciFunc('√³')),
          ],
        ),
        Row(
          children: [
            buildButton('log', () {}, () => sciFunc('log')),
            buildButton('ln', () {}, () => sciFunc('ln')),
            buildButton('x²', () {}, () => sciFunc('x²')),
            buildButton('x⁻¹', () {}, () => sciFunc('x¯¹')),
          ],
        ),
        Row(
          children: [
            buildButton('logᵧx', () {}, () => opPress('logᵧx')),
            buildButton('2ⁿ', () {}, () => sciFunc('2ⁿ')),
            buildButton('x³', () {}, () => sciFunc('x³')),
            buildButton('xˣ', () {}, () => opPress('^')),
          ],
        ),
      ],
    );
  }

  Widget buildProgrammerPad() {
    dynamic children;
    if (activeProgrammerKey == 'HEX') {
      children = [
        buildButton('A', () {}, () => numPress('A')),
        buildButton('B', () {}, () => numPress('B')),
        buildButton('C', () {}, () => numPress('C')),
        buildButton('D', () {}, () => numPress('D')),
        buildButton('E', () {}, () => numPress('E')),
        buildButton('F', () {}, () => numPress('F')),
      ];
    } else {
      children = [Container()];
    }

    return Column(
      children: [
        Row(children: children),
        Row(
          children: [
            buildButton(
              'BIN',
                  () {},
                  () {
                try {
                  int num = int.parse(display, radix: currentBase);
                  setState(() {
                    display = num.toRadixString(2).toUpperCase();
                    shouldResetDisplay = true;
                    activeProgrammerKey = 'BIN'; // ✅ تمييز الزر
                    currentBase = 2;
                  });
                } catch (_) {
                  setState(() {
                    display = 'Error';
                  });
                }
              },
              color: activeProgrammerKey == 'BIN' ? Colors.blue : null,
              textColor:
              activeProgrammerKey == 'BIN' ? Colors.white : Colors.black,
            ),
            buildButton(
              'OCT',
                  () {},
                  () {
                try {
                  int num = int.parse(display, radix: currentBase);
                  setState(() {
                    display = num.toRadixString(8).toUpperCase();
                    shouldResetDisplay = true;
                    activeProgrammerKey = 'OCT'; // ✅
                    currentBase = 8;
                  });
                } catch (_) {
                  setState(() {
                    display = 'Error';
                  });
                }
              },
              color: activeProgrammerKey == 'OCT' ? Colors.blue : null,
              textColor:
              activeProgrammerKey == 'OCT' ? Colors.white : Colors.black,
            ),
            buildButton(
              'DEC',
                  () {},
                  () {
                try {
                  int num = int.parse(display, radix: currentBase);
                  setState(() {
                    display = num.toString();
                    shouldResetDisplay = true;
                    activeProgrammerKey = 'DEC'; // ✅
                    currentBase = 10;
                  });
                } catch (_) {
                  setState(() {
                    display = 'Error';
                  });
                }
              },
              color: activeProgrammerKey == 'DEC' ? Colors.blue : null,
              textColor:
              activeProgrammerKey == 'DEC' ? Colors.white : Colors.black,
            ),
            buildButton(
              'HEX',
                  () {},
                  () {
                try {
                  int num = int.parse(display, radix: currentBase);
                  setState(() {
                    display = num.toRadixString(16).toUpperCase();
                    shouldResetDisplay = true;
                    activeProgrammerKey = 'HEX'; // ✅
                    currentBase = 16;
                  });
                } catch (_) {
                  setState(() {
                    display = 'Error';
                  });
                }
              },
              color: activeProgrammerKey == 'HEX' ? Colors.blue : null,
              textColor:
              activeProgrammerKey == 'HEX' ? Colors.white : Colors.black,
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Simple Calculator'), centerTitle: true),
      body: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () => modeChange('basic'),
                child: const Text('Basic'),
              ),
              ElevatedButton(
                onPressed: () => modeChange('scientific'),
                child: const Text('Scientific'),
              ),
              ElevatedButton(
                onPressed: () => modeChange('programmer'),
                child: const Text('Programmer'),
              ),
            ],
          ),
          Expanded(
            child: Container(
              alignment: Alignment.bottomRight,
              padding: const EdgeInsets.all(24),
              child: Text(
                display,
                style: const TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          if (mode == 'scientific') buildScientificPad(),
          if (mode == 'programmer') buildProgrammerPad(),
          Column(
            children: [
              Row(
                children: [
                  buildButton(
                    'AC',
                        () {},
                    clear,
                    color: Colors.orange,
                    textColor: Colors.white,
                  ),
                  buildButton('⌫', () {}, delete),
                  buildButton('±', () {}, toggleSign),
                  buildButton(
                    '÷',
                        () {},
                        () => opPress('÷'),
                    color: Colors.blue,
                    textColor: Colors.white,
                  ),
                ],
              ),
              Row(
                children: [
                  buildButton('7', () {}, () => numPress('7')),
                  buildButton('8', () {}, () => numPress('8')),
                  buildButton('9', () {}, () => numPress('9')),
                  buildButton(
                    '×',
                        () {},
                        () => opPress('×'),
                    color: Colors.blue,
                    textColor: Colors.white,
                  ),
                ],
              ),
              Row(
                children: [
                  buildButton('4', () {}, () => numPress('4')),
                  buildButton('5', () {}, () => numPress('5')),
                  buildButton('6', () {}, () => numPress('6')),
                  buildButton(
                    '-',
                        () {},
                        () => opPress('-'),
                    color: Colors.blue,
                    textColor: Colors.white,
                  ),
                ],
              ),
              Row(
                children: [
                  buildButton('1', () {}, () => numPress('1')),
                  buildButton('2', () {}, () => numPress('2')),
                  buildButton('3', () {}, () => numPress('3')),
                  buildButton(
                    '+',
                        () {},
                        () => opPress('+'),
                    color: Colors.blue,
                    textColor: Colors.white,
                  ),
                ],
              ),
              Row(
                children: [
                  buildButton('0', () {}, () => numPress('0')),
                  buildButton('.', () {}, decimal),
                  buildButton('d↔f', () {}, () => fraction()),
                  buildButton(
                    '=',
                        () {},
                    calculate,
                    color: Colors.green,
                    textColor: Colors.white,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}