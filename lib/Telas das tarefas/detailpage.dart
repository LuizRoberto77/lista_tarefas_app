import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:lista_tarefas_app/Telas%20das%20tarefas/lista_tarefas.dart';
//import 'package:get/get.dart';
import 'deletetask.dart';
//import 'lista_tarefas.dart';
//import 'package:lista_repo/main.dart';

class Task {
  final int? id;
  final String? nome;
  final int? realized;
  final String? message;

  Task({
    this.id,
    this.nome,
    this.realized,
    this.message,
  });

  // converte o formato JSON para um objeto "Pessoa"
  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'],
      nome: json['name'],
      message: json['message'],
      realized: json['realized'],
    );
  }
}

class DetailPage extends StatefulWidget {
  // ignore: use_key_in_widget_constructors
  const DetailPage({key, required this.tasks, required this.conteudo});
  // ignore: prefer_typing_uninitialized_variables
  final tasks;
  final List conteudo;

  @override
  DetailPagestate createState() => DetailPagestate();
}

class DetailPagestate extends State<DetailPage> {
  // recebe os dados da tela anterior (origem)
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController nomeController = TextEditingController();

  int _radioValue1 = 0;

  //  Variáveis do ambiente que receberão os dados da API
  String _mensagem = '';

  // Documentação da API
  // https://github.com/EdsonMSouza/php-api-to-do-list

  // Endereço da API
  Uri url = Uri.parse('http://emsapi.esy.es/todolist/api/task/update/');

  // Método para requisição da API
  _jsonRestApiHttp() async {
    // esse bloco de código envia a requisição ao servidor da API
    if (nomeController.text != "") {
      http.Response response = await http.put(
        url,
        headers: <String, String>{
          "Content-Type": "Application/json; charset=UTF-8",
          "Authorization": widget.conteudo[3]
          //Tokens C850DC343D3E73FE14DA, 123
        },
        body: jsonEncode(<String, String>{
          "id": widget.tasks.id.toString(),
          "name": nomeController.text,
          "realized": _radioValue1.toString(),
        }),
      );

      // Bloco que recupera a informação do servidor e converte JSON para objeto
      final parsed = json.decode(response.body);
      var tarefa = Task.fromJson(parsed);

      // Vamos mostrar os dados na tela do APP, tratando os erros

      try {
        // deu bom, Editou!!!
        nomeController.text = '';
        setState(() {
          _mensagem = tarefa.message.toString();
          if (_mensagem == 'Task Successfully Updated') {
            _mensagem = 'Tarefa Foi Atualizada!';
            showAlertDialog(context);
          }
        });
      } catch (e) {
        nomeController.text = '';
        setState(() {
          _mensagem = tarefa.message.toString();
          if (_mensagem == 'Task(s) not found') {
            _mensagem = 'Tarefa não encontrada';
          }
        });
      }
    } else {
      setState(() {
        _mensagem = 'Digite algum nome para atualizar a tarefa!';
      });
    }
  }

  @override
  void initState() {
    super.initState();

    nomeController = TextEditingController(text: widget.tasks.name);
  }

  showAlertDialog(BuildContext context) {
    // set up the button
    Widget okButton = TextButton(
      child: const Text("OK"),
      onPressed: () async {
        Navigator.of(context, rootNavigator: true).pop();
        await Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => Lista_tarefas(conteudo: widget.conteudo),
        ));
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: const Text("Atualizar Tarefa"),
      content: const Text("Tarefa foi Atualizada!"),
      actions: [
        okButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Lista de tarefas'),
        ),
        body: Container(
            padding: const EdgeInsets.all(32.0),
            child: Column(children: [
              ListTile(
                  title: Text(widget.tasks.name,
                      style: const TextStyle(fontWeight: FontWeight.w500)),
                  subtitle: Text(widget.tasks.date),
                  leading: widget.tasks.realized != 0
                      ? const Icon(Icons.verified, color: Colors.blue)
                      : const Icon(Icons.unpublished, color: Colors.red)),
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
                  child: Column(children: [
                    TextField(
                      controller: nomeController,
                      decoration: const InputDecoration(
                        labelText: 'Novo nome da tarefa: ',
                      ),
                    ),
                    Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Radio(
                            value: 1,
                            groupValue: _radioValue1,
                            onChanged: (value) async {
                              setState(() {
                                _radioValue1 = 1;
                              });
                            },
                            toggleable: true,
                          ),
                          const Text(
                            'Tarefa Realizada',
                            style: TextStyle(fontSize: 16.0),
                          ),
                          Radio(
                            value: 0,
                            autofocus: true,
                            groupValue: _radioValue1,
                            onChanged: (value) async {
                              setState(() {
                                _radioValue1 = 0;
                              });
                            },
                            toggleable: true,
                          ),
                          const Text(
                            'Tarefa Não Realizada',
                            style: TextStyle(
                              fontSize: 16.0,
                            ),
                          ),
                        ]),
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
                    Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          MaterialButton(
                              height: 50,
                              color: Colors.blue,
                              child: const Text('Atualizar',
                                  style: TextStyle(
                                      fontSize: 16.0, color: Colors.white)),
                              onPressed: () {
                                _jsonRestApiHttp();
                              }),
                          const SizedBox(
                            width: 30,
                          ),
                          MaterialButton(
                              height: 50,
                              color: Colors.red,
                              child: const Text('Deletar',
                                  style: TextStyle(
                                      fontSize: 16.0, color: Colors.white)),
                              onPressed: () async {
                                final Delete dele = Delete();
                                dele.delete_jsonRestApiHttp(
                                    widget.tasks.id, widget.conteudo[3]);
                                await dele.showAlertDialog(
                                    context, widget.conteudo);
                              }),
                        ])
                  ]))
            ])));
  }
}
