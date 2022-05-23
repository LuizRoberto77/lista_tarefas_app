import 'package:flutter/material.dart';
import 'dart:convert'; // trabalha com o json
import 'package:http/http.dart' as http; // trabalha com o protocolo HTTP

class Pessoa {
  final int? id;
  final String message;
  final String? token;

  Pessoa({this.id, required this.message, this.token});

  // converte o formato JSON para um objeto "Pessoa"
  factory Pessoa.fromJson(Map<String, dynamic> json) {
    return Pessoa(
      id: json['id'],
      message: json['message'],
      token: json['token'],
    );
  }
}

class Cadastro extends StatefulWidget {
  const Cadastro({key}) : super(key: key);

  @override
  CadastroState createState() => CadastroState();
}

class CadastroState extends State<Cadastro> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController nomeController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController userController = TextEditingController();
  TextEditingController senhaController = TextEditingController();

  //  Variáveis do ambiente que receberão os dados da API
  int _id = 0;
  String _mensagem = '';
  String _token = '';

  // Documentação da API
  // https://github.com/EdsonMSouza/php-api-to-do-list

  // Endereço da API
  Uri url = Uri.parse('http://emsapi.esy.es/todolist/api/user/new/');

  // Método para requisição da API
  _jsonRestApiHttp() async {
    // esse bloco de código envia a requisição ao servidor da API
    http.Response response = await http.post(
      url,
      headers: <String, String>{
        "Content-Type": "Application/json; charset=UTF-8"
      },
      body: jsonEncode(<String, String>{
        "name": nomeController.text,
        "email": emailController.text,
        "username": userController.text,
        "password": senhaController.text
      }),
    );

    // Bloco que recupera a informação do servidor e converte JSON para objeto
    final parsed = json.decode(response.body);
    var pessoa = Pessoa.fromJson(parsed);

    // Vamos mostrar os dados na tela do APP, tratando os erros

    try {
      // deu bom, Cadastrou!!!
      nomeController.text = '';
      emailController.text = '';
      userController.text = '';
      senhaController.text = '';
      setState(() {
        _id = pessoa.id!.toInt();
        _token = pessoa.token.toString();
        _mensagem = '';
      });
    } catch (e) {
      nomeController.text = '';
      emailController.text = '';
      userController.text = '';
      senhaController.text = '';
      setState(() {
        _id = 0;
        _token = '';
        _mensagem = pessoa.message.toString();
        if (_mensagem == 'Could Not Add User') {
          _mensagem = 'Não foi possivel adicionar usuario';
        } else if (_mensagem == 'User Already Exists') {
          _mensagem = 'Usuário já existente';
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Tela de Cadastro"),
        ),
        body: Container(
          padding: const EdgeInsets.fromLTRB(10.0, 15.0, 10.0, 0.0),
          child: Form(
            key: _formKey,
            child: Column(children: [
              TextField(
                controller: nomeController,
                decoration: const InputDecoration(
                  labelText: 'Nome: ',
                ),
              ),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: 'Email: ',
                ),
              ),
              TextField(
                controller: userController,
                decoration: const InputDecoration(
                  labelText: 'Nome Usuário: ',
                ),
              ),
              TextField(
                controller: senhaController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'senha: ',
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: 50.0),
                child: SizedBox(
                  height: 50.0,
                  child: Text(
                    _mensagem,
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              MaterialButton(
                  height: 50,
                  color: Colors.blue,
                  child: const Text('Cadastrar',
                      style: TextStyle(fontSize: 16.0, color: Colors.white)),
                  onPressed: () {
                    _jsonRestApiHttp();
                  }),
              const SizedBox(height: 10),
              MaterialButton(
                height: 50,
                color: Colors.blue,
                child: const Text('Voltar para Tela inicial',
                    style: TextStyle(fontSize: 16.0, color: Colors.white)),
                onPressed: () {
                  Navigator.pop(context);
                },
              )
            ]),
          ),
        ));
  }
}
