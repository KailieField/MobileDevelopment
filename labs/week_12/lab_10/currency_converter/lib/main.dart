import 'package:flutter/material.dart';

void main() {
  runApp(const CurrencyConverterApp());
}

class CurrencyConverterApp extends StatelessWidget {
  const CurrencyConverterApp({ super.key });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Currency Converter',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({ super.key });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  final TextEditingController _usdController = TextEditingController();
  final TextEditingController _cadController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Currency Converter'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _usdController,
              decoration: const InputDecoration(
                labelText: 'USD',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                if (value.isEmpty) {
                  _cadController.text = '';
                  return;
                }
                double usd = double.tryParse(value) ?? 0;
                double cad = usd * 1.35;
                _cadController.text = cad.toStringAsFixed(2);
              },
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _cadController,
              decoration: const InputDecoration(
                labelText: 'CAD',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                if (value.isEmpty) {
                  _usdController.text = '';
                  return;
                }
                double cad = double.tryParse(value) ?? 0;
                double usd = cad / 1.35;
                _usdController.text = usd.toStringAsFixed(2);
              },
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _usdController.clear();
                  _cadController.clear();
                });
              },
              child: const Text('Reset'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SummaryScreen(
                      usdAmount: _usdController.text,
                      cadAmount: _cadController.text,
                    ),
                  ),
                );
              },
              child: const Text("Summary"),
            ),
          ],
        ),
      ),
    );
  }
}

class SummaryScreen extends StatelessWidget {
  final String usdAmount;
  final String cadAmount;

  const SummaryScreen({ super.key, required this.usdAmount, required this.cadAmount });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Exchange Summary'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'USD Required: \$${usdAmount}',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 10),
            Text(
              'CAD Equivalent: \$${cadAmount}',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 10),
            const Text(
              'Exchange Rate: 1 USD = 1.35 CAD',
              style: TextStyle(
                fontSize: 15, 
                fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 30),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Back'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}