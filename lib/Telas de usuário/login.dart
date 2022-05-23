import 'package:flutter/material.dart';

import 'dart:convert'; // trabalha com o json
import 'package:http/http.dart' as http; // trabalha com o protocolo HTTP

import 'cadastro.dart';
import 'editar.dart';

class Pessoa {
  final int? id;
  final String? message;
  final String? nome;
  final String? email;
  final String? token;

  Pessoa({this.id, this.message, this.nome, this.email, this.token});

  // converte o formato JSON para um objeto "Pessoa"
  factory Pessoa.fromJson(Map<String, dynamic> json) {
    return Pessoa(
      id: json['id'],
      message: json['message'],
      nome: json['name'],
      email: json['email'],
      token: json['token'],
    );
  }
}

class Login extends StatefulWidget {
  const Login({key}) : super(key: key);

  @override
  Loginstate createState() => Loginstate();
}

class Loginstate extends State<Login> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController usuarioController = TextEditingController();
  TextEditingController senhaController = TextEditingController();

  //  Variáveis do ambiente que receberão os dados da API
  int _id = 0;
  String _nome = '';
  String _email = '';
  String _mensagem = '';
  String _token = '';

  // Documentação da API
  // https://github.com/EdsonMSouza/php-api-to-do-list

  // Endereço da API
  Uri url = Uri.parse('http://emsapi.esy.es/todolist/api/user/login/');

  // Método para requisição da API
  _jsonRestApiHttp() async {
    // esse bloco de código envia a requisição ao servidor da API
    http.Response response = await http.post(
      url,
      headers: <String, String>{
        "Content-Type": "Application/json; charset=UTF-8"
      },
      body: jsonEncode(<String, String>{
        "username": usuarioController.text,
        "password": senhaController.text,
      }),
    );

    // Bloco que recupera a informação do servidor e converte JSON para objeto
    final parsed = json.decode(response.body);

    var pessoa = Pessoa.fromJson(parsed);

    // Vamos mostrar os dados na tela do APP, tratando os erros

    if (pessoa.id != null) {
      // deu bom, achou dados na API
      usuarioController.text = '';
      senhaController.text = '';
      setState(() {
        _id = pessoa.id!.toInt();
        _nome = pessoa.nome.toString();
        _email = pessoa.email.toString();
        _token = pessoa.token.toString();
        _mensagem = '';

        // envia os dados após recuperar da API (se deu certo)
        _enviarDadosOutraTela(context);
      });
    } else if (pessoa.id == null) {
      usuarioController.text = '';
      senhaController.text = '';
      setState(() {
        _id = 0;
        _nome = '';
        _email = '';
        _token = '';
        _mensagem = pessoa.message.toString();
        if (_mensagem == 'Incorrect username and/or password') {
          _mensagem = 'Usuário e/ou senha incorretos';
        }
        // ignore: avoid_print
        print(_mensagem);
      });
    }
  }

  // método para enviar dados para outra tela (view)
  void _enviarDadosOutraTela(BuildContext context) {
    // variável para armazenar os dados que queremos passar à outra tela
    List conteudo = <String>[_id.toString(), _nome, _email, _token];
    // enviar os dados efetivamente, ou seja, abrir a outra tela
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Editar(conteudo: conteudo),
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Tela de Login"),
        ),
        body: Container(
          padding: const EdgeInsets.fromLTRB(10.0, 15.0, 10.0, 0.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextField(
                  controller: usuarioController,
                  decoration: const InputDecoration(
                    labelText: 'Nome Usuário: ',
                  ),
                ),
                TextField(
                  controller: senhaController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Senha: ',
                  ),
                ),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.only(top: 50.0),
                  child: SizedBox(
                    height: 50.0,
                    child: Text(
                      _mensagem,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                Row(children: <Widget>[
                  Expanded(
                      child: MaterialButton(
                          height: 50,
                          color: Colors.blue,
                          child: const Text('Realizar Login',
                              style: TextStyle(
                                  fontSize: 16.0, color: Colors.white)),
                          onPressed: () {
                            _jsonRestApiHttp();
                          })),
                  const SizedBox(width: 20),
                  Expanded(
                      child: MaterialButton(
                          height: 50,
                          color: Colors.blue,
                          child: const Text('Cadastro',
                              style: TextStyle(
                                  fontSize: 16.0, color: Colors.white)),
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (BuildContext context) =>
                                        const Cadastro()));
                          }))
                ])
              ],
            ),
          ),
        ));
  }
}
