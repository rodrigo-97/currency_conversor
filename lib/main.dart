import 'dart:async';
import 'dart:convert';

import 'package:currency_conversor/configs/url.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() async {
  runApp(const MaterialApp(home: Home()));
}

Future<Map> getCurrencyData() async {
  http.Response response = await http.get(apiUrl);

  return json.decode(response.body);
}

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final realController = TextEditingController();
  final dolarController = TextEditingController();
  final euroController = TextEditingController();

  double dolar = 0;
  double euro = 0;

  @override
  void dispose() {
    realController.dispose();
    dolarController.dispose();
    euroController.dispose();
    super.dispose();
  }

  void _handleRealChange(String value) {
    if (value.isNotEmpty) {
      double real = double.parse(value);
      dolarController.text = (real / dolar).toStringAsFixed(2);
      euroController.text = (real / euro).toStringAsFixed(2);
    }

    print("DOLAR ${dolarController.text}");
    print("EURO ${euroController.text}");
  }

  void _handleDolarChange(String value) {
    if (value.isNotEmpty) {
      double dolar = double.parse(value);
      realController.text = (dolar * this.dolar).toStringAsFixed(2);
      realController.text = (dolar * this.dolar / euro).toStringAsFixed(2);
    }
  }

  void _handleEuroChange(String value) {
    if (value.isNotEmpty) {
      double euro = double.parse(value);
      realController.text = (euro * this.euro).toStringAsFixed(2);
      dolarController.text = (euro * this.euro / dolar).toStringAsFixed(2);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("Conversor monetário \$"),
      ),
      body: FutureBuilder<Map>(
        future: getCurrencyData(),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
            case ConnectionState.waiting:
              return Center(
                child: Text("Buscando informações das moedas"),
              );
            default:
              if (snapshot.hasError) {
                return Center(
                  child: Text("Erro ao carregar dados monetários"),
                );
              } else {
                dolar = snapshot.data!["results"]["currencies"]["USD"]["buy"];
                euro = snapshot.data!["results"]["currencies"]["EUR"]["buy"];
                return SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Icon(
                          Icons.monetization_on,
                          size: 120.0,
                          color: Colors.blue,
                        ),
                        buildTextField(
                          "R\$",
                          "R\$",
                          realController,
                          _handleRealChange,
                        ),
                        Divider(),
                        buildTextField(
                          "EU",
                          "EU",
                          dolarController,
                          _handleEuroChange,
                        ),
                        Divider(),
                        buildTextField(
                          "US",
                          "US",
                          euroController,
                          _handleDolarChange,
                        ),
                      ],
                    ),
                  ),
                );
              }
          }
        },
      ),
    );
  }
}

Widget buildTextField(
  String label,
  String prefix,
  TextEditingController controller,
  Function(String) handleChange,
) {
  return TextField(
    keyboardType: TextInputType.number,
    onChanged: handleChange,
    controller: controller,
    decoration: InputDecoration(
      labelText: label,
      prefix: Text(prefix.padRight(2)),
      border: OutlineInputBorder(),
      labelStyle: TextStyle(
        color: Colors.blue,
        fontSize: 20,
      ),
    ),
  );
}
