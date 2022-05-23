import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:lista_tarefas_app/Telas%20de%20usu%C3%A1rio/editar.dart';

import 'detailpage.dart';
import 'newtask.dart';

//classe que faz o parser do JSON Retornado da API
class Task {
  final int id;
  final int userId;
  final String name;
  final String date;
  final int realized;
  final String? message;

  Task(this.id, this.userId, this.name, this.date, this.realized, this.message);

  Task.fromJson(Map json)
      : id = json['id'],
        userId = json['userId'],
        name = json['name'],
        date = json['date'],
        realized = json['realized'],
        message = json['message'];
}

class Lista_tarefas extends StatefulWidget {
  // ignore: use_key_in_widget_constructors
  const Lista_tarefas({key, required this.conteudo});
  // ignore: prefer_typing_uninitialized_variables
  final List conteudo;

  @override
  Lista_tarefasstate createState() => Lista_tarefasstate();
}

class Lista_tarefasstate extends State<Lista_tarefas> {
  var tasks = [];

  Uri url = Uri.parse('http://emsapi.esy.es/todolist/api/task/search/');

  Future getTasks() async {
    return await http.post(url, headers: <String, String>{
      "Content-type": "Application/json; charset=UTF-8",
      "Authorization": widget.conteudo[3]
      //Tokens C850DC343D3E73FE14DA, 123
    });
  }

  _getTasks() {
    getTasks().then((response) {
      setState(() {
        try {
          Iterable lista = json.decode(response.body);
          tasks = lista.map((model) => Task.fromJson(model)).toList();
        } catch (e) {
          showAlertDialog(context);
        }
      });
    });
  }

  @override
  void initState() {
    super.initState();

    _getTasks();
  }

  showAlertDialog(BuildContext context) {
    // set up the button
    Widget okButton = TextButton(
      child: const Text("OK"),
      onPressed: () async {
        Navigator.of(context, rootNavigator: true).pop();
        await Navigator.of(context)
            .push(MaterialPageRoute(
              builder: (_) => NewTask(
                conteudo: widget.conteudo[3],
              ),
            ))
            .then((val) => {_getTasks()});
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: const Text("Lista Tarefa Vazia"),
      content: const Text(
          "A lista de tarefas está vazia adicione uma para continuar!"),
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
          title: const Text("Lista de tarefas"),
          leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (BuildContext context) =>
                            Editar(conteudo: widget.conteudo)));
              }),
        ),
        body: ListView.builder(
            itemCount: tasks.length,
            itemBuilder: (context, index) {
              return ListTile(
                leading: tasks[index].realized != 0
                    ? const Icon(Icons.verified, color: Colors.blue)
                    : const Icon(Icons.unpublished, color: Colors.red),
                title: Text(tasks[index].name,
                    style:
                        const TextStyle(fontSize: 20.0, color: Colors.black)),
                subtitle: Text(tasks[index].date),
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DetailPage(
                            tasks: tasks[index], conteudo: widget.conteudo),
                      )).then((val) => {_getTasks()});
                },
              );
            }),
        floatingActionButton: FloatingActionButton(
            child: const Icon(Icons.add),
            onPressed: () {
              Navigator.of(context)
                  .push(MaterialPageRoute(
                    builder: (_) => NewTask(
                      conteudo: widget.conteudo[3],
                    ),
                  ))
                  .then((val) => {_getTasks()});
            }));
  }
} 

/*Uri url = Uri.parse('http://emsapi.esy.es/todolist/api/task/search/');

//API
class API {
  static Future getTasks(token) async {
    return await http.post(url, headers: <String, String>{
      "Content-type": "Application/json; charset=UTF-8",
      "Authorization": token
      //Tokens C850DC343D3E73FE14DA, 123
    });
  }
}

class Lista_tarefas extends StatelessWidget {
  const Lista_tarefas({key, required this.token});
  final String token;

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lista APIRest',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const BuildListView(
        token: '',
      ),
    );
  }
}

class BuildListView extends StatefulWidget {
  const BuildListView({key, required this.token});
  final String token;
  @override
  // ignore: no_logic_in_create_state
  _BuildListViewState createState() => _BuildListViewState(token: '');
}

class _BuildListViewState extends State<BuildListView> {
  //contruir um ambiente para consumir a API e o builder da lista
  _BuildListViewState({key, required this.token}) {
    _getTasks(token);
  }
  final String token;
  var tasks = [];

  _getTasks(String token) {
    API.getTasks(token).then((response) {
      setState(() {
        Iterable lista = json.decode(response.body);
        tasks = lista.map((model) => Task.fromJson(model)).toList();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Lista de tarefas"),
        ),
        body: listaTarefas(),
        floatingActionButton: FloatingActionButton(
          child: const Icon(Icons.add),
          onPressed: () {
            Navigator.of(context)
                .push(MaterialPageRoute(
                  builder: (_) => const NewTask(
                    token: '',
                  ),
                ))
                .then((val) => {_getTasks(token)});
          },
        ));
  }

  //Constrói a lista, ou  seja, o widget listView (ListView.builder)
  listaTarefas() {
    return ListView.builder(
        itemCount: tasks.length,
        itemBuilder: (context, index) {
          return ListTile(
            leading: tasks[index].realized != 0
                ? const Icon(Icons.verified, color: Colors.blue)
                : const Icon(Icons.unpublished, color: Colors.red),
            title: Text(tasks[index].name,
                style: const TextStyle(fontSize: 20.0, color: Colors.black)),
            subtitle: Text(tasks[index].date),
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        DetailPage(tasks: tasks[index], token: token),
                  )).then((val) => {_getTasks(token)});
            },
          );
        });
  }
}*/
