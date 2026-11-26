import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

const String urlBase = "http://10.106.76.12:8080";

void main() {
  runApp(const MeuApp());
}

class MeuApp extends StatelessWidget {
  const MeuApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Atividades do Dia',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: Colors.indigo,
        useMaterial3: true,
      ),
      home: const TelaAtividades(),
    );
  }
}

class TelaAtividades extends StatefulWidget {
  const TelaAtividades({super.key});

  @override
  State<TelaAtividades> createState() => _TelaAtividadesState();
}

class _TelaAtividadesState extends State<TelaAtividades> {
  final TextEditingController _dia = TextEditingController();
  final TextEditingController _atividade = TextEditingController();
  final Map<String, String> _meses = {};
  DateTime _mes = DateTime(DateTime.now().year, DateTime.now().month);
  List _atividades = [];
  bool _carregando = false;
  bool _salvando = false;

  @override
  void initState() {
    super.initState();
    final hoje = DateTime.now();
    _dia.text = hoje.day.toString();

    for (int i = 0; i < 24; i++) {
      final data = DateTime(hoje.year, hoje.month - i);
      final valor = '${data.year}-${data.month.toString().padLeft(2, '0')}';
      _meses[valor] = '${_nomeMes(data.month)} de ${data.year}';
    }

    _carregar();
  }

  @override
  void dispose() {
    _dia.dispose();
    _atividade.dispose();
    super.dispose();
  }

  String get _mesEscolhido =>
      '${_mes.year}-${_mes.month.toString().padLeft(2, '0')}';

  String _nomeMes(int mes) {
    const nomes = [
      'Janeiro',
      'Fevereiro',
      'Março',
      'Abril',
      'Maio',
      'Junho',
      'Julho',
      'Agosto',
      'Setembro',
      'Outubro',
      'Novembro',
      'Dezembro',
    ];
    return nomes[mes - 1];
  }

  String _dataCurta(String dia) {
    return '${dia.substring(8, 10)}/${dia.substring(5, 7)}/${dia.substring(0, 4)}';
  }

  Future<void> _carregar() async {
    setState(() => _carregando = true);

    try {
      final resposta = await http
          .get(Uri.parse('$urlBase/listar.php?mes=$_mesEscolhido'))
          .timeout(const Duration(seconds: 15));

      if (!mounted) return;
      setState(() => _atividades = jsonDecode(resposta.body));
    } catch (e) {
      if (!mounted) return;
      setState(() => _atividades = []);
      _mostrar('Erro de conexão: $e');
    }

    if (mounted) setState(() => _carregando = false);
  }

  Future<void> _salvar() async {
    final numeroDia = int.tryParse(_dia.text.trim()) ?? 0;
    final ultimoDia = DateTime(_mes.year, _mes.month + 1, 0).day;

    if (numeroDia < 1 || numeroDia > ultimoDia) {
      _mostrar('Digite um dia entre 1 e $ultimoDia.');
      return;
    }

    if (_atividade.text.trim().isEmpty) {
      _mostrar('Digite a atividade.');
      return;
    }

    setState(() => _salvando = true);

    try {
      final dia = '$_mesEscolhido-${numeroDia.toString().padLeft(2, '0')}';
      final resposta = await http.post(
        Uri.parse('$urlBase/salvar.php'),
        body: {
          'dia': dia,
          'atividade': _atividade.text.trim(),
        },
      ).timeout(const Duration(seconds: 15));

      if (!mounted) return;

      if (resposta.statusCode == 200) {
        _atividade.clear();
        _mostrar('Atividade salva.');
        await _carregar();
      } else {
        _mostrar('Erro ao salvar a atividade.');
      }
    } catch (e) {
      if (!mounted) return;
      _mostrar('Erro de conexão: $e');
    }

    if (mounted) setState(() => _salvando = false);
  }

  void _mostrar(String mensagem) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensagem)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Atividades do Dia'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: _mesEscolhido,
                          isExpanded: true,
                          decoration: const InputDecoration(
                            labelText: 'Mês',
                            border: OutlineInputBorder(),
                          ),
                          items: _meses.entries
                              .map((mes) => DropdownMenuItem<String>(
                                    value: mes.key,
                                    child: Text(
                                      mes.value,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ))
                              .toList(),
                          onChanged: (valor) {
                            if (valor == null) return;
                            final partes = valor.split('-');
                            setState(() {
                              _mes = DateTime(
                                int.parse(partes[0]),
                                int.parse(partes[1]),
                              );
                            });
                            _carregar();
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      SizedBox(
                        width: 90,
                        child: TextField(
                          controller: _dia,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Dia',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _atividade,
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => _salvar(),
                    decoration: const InputDecoration(
                      labelText: 'Atividade',
                      hintText: 'Ex.: Estudar Dart',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: _salvando ? null : _salvar,
                    icon: _salvando
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.save),
                    label: Text(_salvando ? 'Salvando...' : 'Salvar atividade'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Atividades do mês',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              IconButton(
                tooltip: 'Atualizar',
                onPressed: _carregando ? null : _carregar,
                icon: const Icon(Icons.refresh),
              ),
            ],
          ),
          if (_carregando)
            const Padding(
              padding: EdgeInsets.all(32),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (_atividades.isEmpty)
            const Padding(
              padding: EdgeInsets.all(32),
              child: Center(child: Text('Nenhuma atividade neste mês.')),
            )
          else
            for (final item in _atividades)
              Card(
                child: ListTile(
                  leading: CircleAvatar(
                    child: Text(item['dia'].toString().substring(8, 10)),
                  ),
                  title: Text(item['atividade'].toString()),
                  subtitle: Text(_dataCurta(item['dia'].toString())),
                ),
              ),
        ],
      ),
    );
  }
}
