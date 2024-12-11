import 'package:flutter/material.dart';
import 'package:math_expressions/math_expressions.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String userInput = "";
  String result = "0";
  bool isNewCalculation = false; // To track whether it's a new calculation

  // List of buttons to display on the calculator
  List<String> buttonList = [
    "AC",
    "(",
    ")",
    "/",
    "7",
    "8",
    "9",
    "*",
    "4",
    "5",
    "6",
    "+",
    "1",
    "2",
    "3",
    "-",
    "C",
    "0",
    ".",
    "=",
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Column(
          children: [
            Container(
              height: MediaQuery.of(context).size.height /
                  3, // Allocates 1/3 of the screen height
              child: resultWidget(), // Widget to display the result
            ),
            Expanded(
                child: buttonWidget()), // Widget to display calculator buttons
          ],
        ),
      ),
    );
  }

  // Widget to display the input and the result
  Widget resultWidget() {
    return Container(
      color: Colors.white, // Background color of the display area
      child: Column(
        mainAxisAlignment:
            MainAxisAlignment.end, // Aligns content to the bottom
        children: [
          // User input display
          Container(
            padding: const EdgeInsets.all(20),
            alignment: Alignment.centerRight,
            child: Text(
              userInput,
              style: const TextStyle(
                fontSize: 32,
                color: Colors.black54,
              ),
            ),
          ),
          // Display the result
          Container(
            padding: const EdgeInsets.all(10),
            alignment: Alignment.centerRight,
            child: Text(
              result,
              style: const TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Create the button grid
  Widget buttonWidget() {
    //Generates the grid of calculator buttons dynamically
    return Container(
      padding: const EdgeInsets.all(10), //Adds padding around the entire grid
      color: const Color.fromARGB(
          255, 240, 240, 240), //Sets the background color of the grid

      //Dynamically creates a grid layout for the buttons using a builder function.
      child: GridView.builder(
        itemCount: buttonList.length,

        //Defines the layout structure of the grid
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4, // 4 buttons per row
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),

        //Dynamically builds each button using the button function
        itemBuilder: (context, index) {
          return button(buttonList[index]);
        },
      ),
    );
  }

  // Function to determine the text color for each button
  Color getColor(String text) {
    if (text == "/" ||
        text == "*" ||
        text == "+" ||
        text == "-" ||
        text == "(" ||
        text == ")") {
      return Colors.redAccent;
    }
    if (text == "=" || text == "AC") {
      return Colors.white; // Special buttons are white
    }
    return Colors.indigo; // Numbers and others are indigo
  }

  // Function to determine the background color for each button
  Color getBgColor(String text) {
    if (text == "AC") {
      return Colors.redAccent; // AC button is red
    }
    if (text == "=") {
      return const Color.fromARGB(255, 104, 204, 159); // Equals button is green
    }
    if (text == "C") {
      return Colors.redAccent; // "C" button is also red
    }
    return Colors.white; // Default background is white
  }

  // Widget for individual buttons
  Widget button(String text) {
    return InkWell(
      onTap: () {
        setState(() {
          handleButtonPress(text); // Handle button presses
        });
      },
      child: Container(
        decoration: BoxDecoration(
          color: getBgColor(text),
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 1,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              color: getColor(text),
              fontSize: 30,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  // Function to handle logic for button presses
  void handleButtonPress(String text) {
    if (text == "AC") {
      userInput = ""; // Clear input
      result = "0"; // Reset result
      isNewCalculation = false; // Reset new calculation flag
      return;
    }

    if (text == "C") {
      if (userInput.isNotEmpty) {
        userInput = userInput.substring(
            0, userInput.length - 1); // Remove last character
      }
      return;
    }

    if (text == "=") {
      result = calculate(); // Calculate the result
      isNewCalculation = true; // Mark as completed calculation
      return;
    }

    // Prevent multiple consecutive operators
    if (_isOperator(text)) {
      if (userInput.isNotEmpty &&
          _isOperator(userInput[userInput.length - 1])) {
        // Do nothing if the last character is already an operator
        return;
      }
    }

    // If it's a new calculation and an operator is pressed, start a new calculation
    if (isNewCalculation && !_isNumberOrDot(text)) {
      userInput = result + text; // Start with the previous result
      isNewCalculation = false; // Reset flag
    } else if (isNewCalculation && _isNumberOrDot(text)) {
      // If it's a number after "=" is pressed, just add the number
      userInput = text;
      isNewCalculation = false;
    } else {
      userInput += text; // Add the new input to the string
    }
  }

  // Helper to check if input is a number or "."
  bool _isNumberOrDot(String text) {
    return RegExp(r'[0-9.]').hasMatch(text);
  }

  // Helper to check if input is an operator
  bool _isOperator(String text) {
    return RegExp(r'[+\-*/]').hasMatch(text);
  }

  // Perform the calculation
  String calculate() {
    try {
      String processedInput =
          preprocessInput(userInput); // Preprocess input for formatting
      Parser parser = Parser();
      Expression expression = parser.parse(processedInput);
      ContextModel contextModel = ContextModel();
      double eval = expression.evaluate(EvaluationType.REAL, contextModel);

      // Return the result as an integer if possible, otherwise as a decimal
      if (eval == eval.toInt()) {
        return eval.toInt().toString();
      } else {
        return eval.toStringAsFixed(2);
      }
    } catch (e) {
      return "Error"; // Return "Error" for invalid input
    }
  }

  // Preprocess user input for implicit multiplication
  String preprocessInput(String input) {
    // Insert `*` between numbers and opening parentheses, or between closing parentheses and numbers
    input =
        input.replaceAllMapped(RegExp(r'(\d)(\()'), (match) => '${match[1]}*(');
    input =
        input.replaceAllMapped(RegExp(r'(\))(\d)'), (match) => ')*${match[2]}');
    return input;
  }
}

void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: HomeScreen(), // Run the calculator app
  ));
}
