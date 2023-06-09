import 'package:flutter/material.dart';

String getFullName(String firstName, String lastName) {
  return "$firstName $lastName";
}

class LivingThing {
  void breathe() {
    print('I am breathing');
  }
}

class Person extends LivingThing {
  String name;
  int age;

  Person(this.name, this.age);

  // we have added a factory constructor Person.fromJson that creates a Person object from a JSON representation.
  // The factory constructor takes a Map<String, dynamic>
  // as a parameter, which represents the JSON data.

  factory Person.fromJson(Map<String, dynamic> json) {
    String name = json['name'];
    int age = json['age'];
    return Person(name, age);
  }

  String? get getName {
    return name;
  }

  set setName(String name) {
    this.name = name;
  }

  void build() {
    print("building");
  }

  void introduction() {
    print("Hello my name is ${name.toLowerCase()} , and I am $age years old");
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Person && other.name == name && other.age == age;
  }

  // The hashCode getter is overridden to calculate a hash code for the Person object.
  // It combines the hash codes of the name and age properties using the XOR operator (^).
  @override
  int get hashCode => name.hashCode ^ age.hashCode;

  // To use a Future method in your class, you can define an asynchronous method that returns a Future object.
  // Here's an example of adding a Future method named fetchData to your Person class:
  // Future<double> calculateSalary(){
  //   // Simulating an asynchronous operation, such as fetching data from a remote server
  //   await Future.delayed(const Duration(seconds: 2));
  //   // Perform your asynchronous logic here
  //   double baseSalary = 5000;
  //   double salary = baseSalary + (age * 100);
  //   return salary;
  // }
}

extension PersonExtensions on Person {
  bool get isAdult => age >= 18;
}

Map<String, dynamic> createJsonMap(String name, int age) {
  Map<String, dynamic> json = {
    'name': name,
    'age': age,
  };
  return json;
}



enum AnimalType { cat, dog, bunny }

void comparingWithSwitch(AnimalType animalType) {
  switch (animalType) {
    case AnimalType.cat:
      print("It's a cat");
      break;
    case AnimalType.dog:
      print("It's a dog");
      break;
    case AnimalType.bunny:
      print("It's a bunny");
      break;
  }
}

bool comparingWithHashCode(Person person, Person otherPerson) {
  return person == otherPerson;
}

void comparingWithStatements() {
  Person person1 = Person('Ana', 58);
  Person person2 = Person('Fatima', 30);
  if (person1.getName!.toLowerCase() == person2.getName!.toLowerCase()) {
    // Strings are equal (case-insensitive)
    print("Have the same name");
  } else {
    print("Doesn't have the same name");
  }
}

List<String?> names = [];
var firstName = "Michael";
var lastName = "Paliz";
final String name = getFullName(firstName, lastName);

String printName() => getFullName(firstName, lastName);

void printArray() => print(names);

void addName(String? name) {
  names.add(name);
}

// The optionalValue function you provided is correct.
// It takes a nullable list of strings (List<String?>? names) as a parameter and calculates the length of the list.
// If the names list is not null, it returns its length; otherwise, it returns 0. The length value is then printed using string interpolation.

void optionalValue(List<String?>? names) {
  final length = names?.length ?? 0;
  print("This is lenght $length");
}

// void printSalary() async{
//   Person person = Person("Jorge", 20);
//   double salary  = await person.calculateSalary() ;
//   print("Salary: \$${salary.toStringAsFixed(2)}");
//
// }

void main() {
  runApp(const MyApp());
}

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});
//
//   // This widget is the root of your application.
//   @override
//   Future<Widget> build(BuildContext context) async {
//     // ======= BASIC CONCEPTS ======== //
//     // animal(AnimalType.bunny);
//     // addName("Michael");
//     // addName("Jhoan");
//     // addName(null);
//     // printArray();
//     // optionalValue(names);
//
//     // Modifying the value if it is null using ??=
//     // firstName ??= "John";
//     // print(name);
//
//     // ======= ADVANCED CONCEPTS ======== //
//     //Add a person
//     Person person = Person("Michael", 22);
//     final boss = Person("Jhoan", 20);
//     boss.setName = ("Alex");
//     print(person.getName);
//     boss.introduction();
//     person.introduction();
//     person.breathe();
//
//     Person personFromFactory = Person.fromJson(createJsonMap("JHON", 50));
//     personFromFactory.introduction();
//
//     comparingWithStatements();
//
//     print(comparingWithHashCode(person, boss));
//
//     print("Is it an adult? ${personFromFactory.isAdult}");
//
//
//
//     return MaterialApp(
//       title: 'Flutter Demo',
//       theme: ThemeData(
//         colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
//         useMaterial3: true,
//       ),
//       home: const MyHomePage(title: 'Flutter Demo Home Page'),
//     );
//   }
// }

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Flutter Demo Home Page'),
        ),
        body: FutureBuilder<double>(
          future: calculateSalary(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else {
              double salary = snapshot.data ?? 0.0;
              return Text('Salary: \$${salary.toStringAsFixed(2)}');
            }
          },
        ),
      ),
    );
  }

  Future<double> calculateSalary() async {
    // Simulating an asynchronous operation, such as fetching data from a remote server
    await Future.delayed(const Duration(seconds: 2));

    // Perform your salary calculation logic here
    double baseSalary = 5000;
    double salary = baseSalary + 1000; // Replace with your salary calculation

    return salary;
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          //
          // TRY THIS: Invoke "debug painting" (choose the "Toggle Debug Paint"
          // action in the IDE, or press "p" in the console), to see the
          // wireframe for each widget.
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
