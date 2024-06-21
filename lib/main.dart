
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Consulta de CEP',
      home: ConsultaCepPage(),

      debugShowCheckedModeBanner: false,
    );
  }
}


class ConsultaCepPage extends StatefulWidget {
  @override
  _ConsultaCepPageState createState() => _ConsultaCepPageState();
}

class _ConsultaCepPageState extends State<ConsultaCepPage> {
  final TextEditingController _cepController = TextEditingController();
  String _mensagem = '';
  Map<String, dynamic>? _dadosCep;

  void _consultarCep() async {
    final cep = _cepController.text;
    if (cep.length != 8 || !RegExp(r'^[0-9]+$').hasMatch(cep)) {
      setState(() {
        _mensagem = 'CEP inválido. Insira um CEP com 8 números';
        _dadosCep = null;
      });
      return;
    }

    final url = 'https://cep.awesomeapi.com.br/json/$cep';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data.containsKey('status') && data['status'] == 404) {
          setState(() {
            _mensagem = 'CEP não encontrado.';
            _dadosCep = null;
          });
        } else {
          setState(() {
            _mensagem = '';
            _dadosCep = data;
          });
        }
      } else {
        setState(() {
          _mensagem = 'Erro ao consultar o CEP.';
          _dadosCep = null;
        });
      }
    } catch (e) {
      setState(() {
        _mensagem = 'Erro ao consultar o CEP. Verifique sua conexão com a internet.';
        _dadosCep = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 39, 70, 103),
        title: Text('Consulta de CEP'),
        
      ),
      
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _cepController,
              decoration: InputDecoration(
                labelText: 'Digite o CEP',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              maxLength: 8,
            ),
            SizedBox(height: 16.0),

            ElevatedButton(
              onPressed: _consultarCep,
              child: Text('Consultar'),
              style: ElevatedButton.styleFrom(backgroundColor: Color.fromARGB(255, 35, 81, 112))

            ),
            const SizedBox(height: 16.0),
            if (_mensagem.isNotEmpty) 
              Text(
                _mensagem,
                style: const TextStyle(color: Colors.red),
              ),
            if (_dadosCep != null)
              Expanded(
                child: ListView(
                  children: [
                    ListTile(
                      title: const Text('Endereço'),
                      subtitle: Text('${_dadosCep!['address_type']} ${_dadosCep!['address_name']}'),
                    ),
                    ListTile(
                      title: const Text('Bairro'),
                      subtitle: Text('${_dadosCep!['district']}'),
                    ),
                    ListTile(
                      title: const Text('Cidade'),
                      subtitle: Text('${_dadosCep!['city']}'),
                    ),
                    ListTile(
                      title: const Text('Estado'),
                      subtitle: Text('${_dadosCep!['state']}'),
                    ),
                    ListTile(
                      title: const Text('CEP'),
                      subtitle: Text('${_dadosCep!['cep']}'),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}


// versao 1 -