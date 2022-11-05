import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

const request = "https://api.hgbrasil.com/finance?format=json-cors&key=e5bb5abd";

void main() async {
  runApp(
    MaterialApp(
      home: const Home(),
      theme: ThemeData(
        hintColor: Colors.amber,
        primaryColor: Colors.white,
        inputDecorationTheme: const InputDecorationTheme(
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.white),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.amber),
          ),
          hintStyle: TextStyle(
            color: Colors.amber
          ),
        ),
      ),
    ),
  );
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

  double? dolar;
  double? euro;

  void _realChanged(String? text) {
    if(text == null || text.isEmpty) {
      dolarController.text = "";
      euroController.text = "";
      return;
    }

    double real = double.parse(text);
    dolarController.text = dolar != null ? (real/dolar!).toStringAsFixed(2): "";
    euroController.text = euro != null ? (real/euro!).toStringAsFixed(2): "";
  }

  void _dolarChanged(String? text){
    if(text == null || text.isEmpty) {
      realController.text = "";
      euroController.text = "";
      return;
    }

    double dolar = double.parse(text);
    realController.text = this.dolar != null ? (dolar * this.dolar!).toStringAsFixed(2) : "";
    euroController.text =  this.dolar != null ? (dolar * this.dolar! / euro!).toStringAsFixed(2) : "";
  }

  void _euroChanged(String? text){
    if(text == null || text.isEmpty) {
      realController.text = "";
      dolarController.text = "";
      return;
    }
    double euro = double.parse(text);
    realController.text = this.euro != null ? (euro * this.euro!).toStringAsFixed(2) : "-";
      dolarController.text = this.euro != null && dolar != null ? (euro * this.euro! / dolar!).toStringAsFixed(2) : "-";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("\$ Conversor \$"),
        backgroundColor: Colors.amber,
        centerTitle: true,
      ),
      body: FutureBuilder<Map>(
          future: getData(),
          builder: (context, snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.none:
              case ConnectionState.waiting:
                return const Center(
                  child: Text(
                    "Carregando dados...",
                    style: TextStyle(
                      color: Colors.amber,
                      fontSize: 25.0,
                    ),
                    textAlign: TextAlign.center,
                  ),
                );
              default:
                if (snapshot.hasError) {
                  return const Center(
                    child: Text(
                      "Erro no carregamento :(",
                      style: TextStyle(
                        color: Colors.amber,
                        fontSize: 25.0,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  );
                } else {
                  dolar = snapshot.data?["results"]?["currencies"]?["USD"]?["buy"];
                  euro = snapshot.data?["results"]?["currencies"]?["EUR"]?["buy"];

                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(10.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Icon(
                          Icons.monetization_on,
                          size: 150.0,
                          color: Colors.amber,
                        ),
                        buildTextField("Reais", "R\$", realController, _realChanged),
                        const Divider(),
                        buildTextField("Dólares", "US\$", dolarController, _dolarChanged),
                        const Divider(),
                        buildTextField("Euros", "€", euroController, _euroChanged),
                      ],
                    ),
                  );
                }
            }
          }),
    );
  }
}

Widget buildTextField(String label, String prefix, TextEditingController controller,
                      Function(String?) onChangeFunc){
  return TextField(
    controller: controller,
    decoration: InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.amber),
      border: const OutlineInputBorder(),
      prefixText: prefix,
    ),
    style: const TextStyle(
      color: Colors.amber,
      fontSize: 25.0,
    ),
    onChanged: onChangeFunc,
    keyboardType: const TextInputType.numberWithOptions(decimal: true),
  );
}

Future<Map> getData() async {
  http.Response response = await http.get(Uri.parse(request));
  return json.decode(response.body);
}