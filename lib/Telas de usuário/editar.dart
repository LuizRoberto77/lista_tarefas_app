import 'package:flutter/material.dart';

import 'dart:convert'; // trabalha com o json
import 'package:http/http.dart' as http;
import 'package:lista_tarefas_app/Telas%20das%20tarefas/lista_tarefas.dart'; // trabalha com o protocolo HTTP

class Pessoa {
  final String? nome;
  final String? message;
  final String? user;
  final String? email;
  final String token;

  Pessoa({this.user, this.message, this.nome, this.email, required this.token});

  // converte o formato JSON para um objeto "Pessoa"
  factory Pessoa.fromJson(Map<String, dynamic> json) {
    return Pessoa(
      nome: json['name'],
      message: json['message'],
      user: json['username'],
      email: json['email'],
      token: json['token'],
    );
  }
}

class Editar extends StatefulWidget {
  const Editar({key, required this.conteudo}) : super(key: key);
  final List conteudo;

  @override
  editarstate createState() => editarstate();
}

class editarstate extends State<Editar> {
  // recebe os dados da tela anterior (origem)
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController nomeController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController userController = TextEditingController();
  TextEditingController senhaController = TextEditingController();
  TextEditingController tokenController = TextEditingController();

  //  Variáveis do ambiente que receberão os dados da API

  String _mensagem = '';

  // Documentação da API
  // https://github.com/EdsonMSouza/php-api-to-do-list

  // Endereço da API
  Uri url = Uri.parse('http://emsapi.esy.es/todolist/api/user/update/');

  // Método para requisição da API
  _jsonRestApiHttp() async {
    // esse bloco de código envia a requisição ao servidor da API
    http.Response response = await http.put(
      url,
      headers: <String, String>{
        "Content-Type": "Application/json; charset=UTF-8",
        "Authorization": tokenController.text,
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
      // deu bom, Editou!!!
      nomeController.text = '';
      emailController.text = '';
      userController.text = '';
      senhaController.text = '';
      tokenController.text = '';
      setState(() {
        _mensagem = pessoa.message.toString();
        if (_mensagem == 'User Successfully Updated') {
          _mensagem = 'Usuário Atualizado!';
        }
      });
    } catch (e) {
      nomeController.text = '';
      emailController.text = '';
      userController.text = '';
      senhaController.text = '';
      tokenController.text = '';
      setState(() {
        _mensagem = pessoa.message.toString();
        if (_mensagem == 'Could Not Update User') {
          _mensagem = 'Não foi possivel atualizar usuario';
        } else if (_mensagem == 'Incorrect username and/or password') {
          _mensagem = 'Usuário e/ou senha incorretos';
        } else if (_mensagem == 'Token Refused') {
          _mensagem = 'Token Recusado';
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Tela de Edição"),
        ),
        body: Container(
            padding: const EdgeInsets.fromLTRB(10.0, 15.0, 10.0, 0.0),
            child: Column(children: [
              Text(widget.conteudo[0]),
              Text(widget.conteudo[1]),
              Text(widget.conteudo[2]),
              Text(widget.conteudo[3]),
              const Padding(
                padding: EdgeInsets.only(top: 50.0),
                child: SizedBox(
                  height: 50.0,
                  child: Text(
                    "Atualizar",
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              Form(
                key: _formKey,
                child: Column(
                  children: [
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
                    TextField(
                      controller: tokenController,
                      decoration: const InputDecoration(
                        labelText: 'Token: ',
                      ),
                    ),
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
                    MaterialButton(
                        height: 50,
                        color: Colors.blue,
                        child: const Text('Atualizar',
                            style:
                                TextStyle(fontSize: 16.0, color: Colors.white)),
                        onPressed: () {
                          _jsonRestApiHttp();
                        }),
                    const SizedBox(height: 10),
                    MaterialButton(
                      height: 50,
                      color: Colors.blue,
                      child: const Text('Listar tarefas',
                          style:
                              TextStyle(fontSize: 16.0, color: Colors.white)),
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (BuildContext context) =>
                                    Lista_tarefas(conteudo: widget.conteudo)));
                      },
                    )
                  ],
                ),
              ),
            ])));
  }
}
