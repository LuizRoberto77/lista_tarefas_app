import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:lista_tarefas_app/Telas%20das%20tarefas/lista_tarefas.dart';
//import 'package:get/get.dart';

class DTask {
  final String? id;
  final String? message;

  DTask({this.message, this.id});

  // converte o formato JSON para um objeto "Pessoa"
  factory DTask.fromJson(Map<String, dynamic> json) {
    return DTask(
      id: json['id'],
      message: json['message'],
    );
  }
}

class Delete {
  // Documentação da API
  // https://github.com/EdsonMSouza/php-api-to-do-list

  // Endereço da API
  Uri url = Uri.parse('http://emsapi.esy.es/todolist/api/task/delete/');

  // Método para requisição da API
  // ignore: non_constant_identifier_names
  delete_jsonRestApiHttp(task, conteudo) async {
    // esse bloco de código envia a requisição ao servidor da API
    // ignore: unused_local_variable
    http.Response response = await http.delete(
      url,
      headers: <String, String>{
        "Content-Type": "Application/json; charset=UTF-8",
        "Authorization": conteudo[3]
        //Tokens C850DC343D3E73FE14DA, 123
      },
      body: jsonEncode(<String, String>{
        "id": task.toString(),
      }),
    );
  }

  showAlertDialog(BuildContext context, conteudo) {
    // set up the button
    Widget okButton = TextButton(
      child: const Text("OK"),
      onPressed: () async {
        Navigator.of(context, rootNavigator: true).pop();
        await Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => Lista_tarefas(conteudo: conteudo),
        ));
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: const Text("Deletar tarefa"),
      content: const Text("Tarefa foi deletada!"),
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
}
