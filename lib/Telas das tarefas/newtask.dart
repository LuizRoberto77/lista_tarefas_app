import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class Task {
  final String? nome;
  final String? message;

  Task({this.message, this.nome});

  // converte o formato JSON para um objeto "Pessoa"
  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      nome: json['name'],
      message: json['message'],
    );
  }
}

class NewTask extends StatefulWidget {
  const NewTask({Key? key, required this.conteudo}) : super(key: key);
  final String conteudo;
  @override
  NewTaskstate createState() => NewTaskstate();
}

class NewTaskstate extends State<NewTask> {
  // recebe os dados da tela anterior (origem)
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController novaTarefaController = TextEditingController();

  //  Variáveis do ambiente que receberão os dados da API

  String _mensagem = '';

  // Documentação da API
  // https://github.com/EdsonMSouza/php-api-to-do-list

  // Endereço da API
  Uri url = Uri.parse('http://emsapi.esy.es/todolist/api/task/new/');

  // Método para requisição da API
  _jsonRestApiHttp() async {
    // esse bloco de código envia a requisição ao servidor da API
    if (novaTarefaController.text != "") {
      http.Response response = await http.post(
        url,
        headers: <String, String>{
          "Content-Type": "Application/json; charset=UTF-8",
          "Authorization": widget.conteudo
          //Tokens C850DC343D3E73FE14DA, 123
        },
        body: jsonEncode(<String, String>{
          "name": novaTarefaController.text,
        }),
      );

      // Bloco que recupera a informação do servidor e converte JSON para objeto
      final parsed = json.decode(response.body);
      var pessoa = Task.fromJson(parsed);

      // Vamos mostrar os dados na tela do APP, tratando os erros

      try {
        // deu bom, Adicionou!!!
        novaTarefaController.text = '';
        setState(() {
          _mensagem = pessoa.message.toString();
          if (_mensagem == 'Task Successfully Added') {
            _mensagem = 'Nova tarefa adicionada!';
          }
        });
      } catch (e) {
        novaTarefaController.text = '';
        setState(() {
          _mensagem = pessoa.message.toString();
          if (_mensagem == 'Could Not Add Task') {
            _mensagem = 'Não foi possivel adicionar tarefa!';
          }
        });
      }
    } else {
      setState(() {
        _mensagem = 'Digite algum nome para a tarefa!';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Adicionar Tarefa"),
        ),
        body: Container(
            padding: const EdgeInsets.fromLTRB(10.0, 15.0, 10.0, 0.0),
            child: Column(children: [
              const Padding(
                padding: EdgeInsets.only(top: 50.0),
                child: SizedBox(
                  height: 50.0,
                  child: Text(
                    "Nova Tarefa",
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextField(
                      controller: novaTarefaController,
                      decoration: const InputDecoration(
                        labelText: 'Nome da tarefa: ',
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
                        child: const Text('Adicionar',
                            style:
                                TextStyle(fontSize: 16.0, color: Colors.white)),
                        onPressed: () {
                          _jsonRestApiHttp();
                        }),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
            ])));
  }
}
