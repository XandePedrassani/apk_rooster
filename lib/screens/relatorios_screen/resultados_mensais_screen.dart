import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:rooster/services/relatorio_service.dart';

class ResultadosMensaisScreen extends StatefulWidget {
  final int ano;
  final int mes;

  const ResultadosMensaisScreen({
    Key? key,
    required this.ano,
    required this.mes,
  }) : super(key: key);

  @override
  _ResultadosMensaisScreenState createState() => _ResultadosMensaisScreenState();
}

class _ResultadosMensaisScreenState extends State<ResultadosMensaisScreen> {
  final RelatorioService _relatorioService = RelatorioService();
  bool _isLoading = true;
  Map<String, dynamic> _resultados = {};
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _carregarResultados();
  }

  Future<void> _carregarResultados() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final resultados = await _relatorioService.getResultadosMensais(
        widget.ano,
        widget.mes,
      );

      setState(() {
        _resultados = resultados;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Erro ao carregar resultados: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final formatoMoeda = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
    final nomeMes = DateFormat('MMMM', 'pt_BR').format(DateTime(widget.ano, widget.mes));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Resultados Mensais'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
              ? Center(child: Text(_errorMessage, style: const TextStyle(color: Colors.red)))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Período: ${nomeMes.toUpperCase()}/${widget.ano}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'FATURAMENTO TOTAL: ${formatoMoeda.format(_resultados['faturamentoTotal'])}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 22,
                                  color: Colors.green,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Faturamento por Semana',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                              const SizedBox(height: 16),
                              SizedBox(
                                height: 200,
                                child: _buildFaturamentoChart(),
                              ),
                              const SizedBox(height: 16),
                              ..._resultados['faturamentoPorSemana'].map<Widget>((semana) {
                                return Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(semana['periodo']),
                                      Text(
                                        formatoMoeda.format(semana['valor']),
                                        style: const TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Serviços por Status',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                              const SizedBox(height: 16),
                              SizedBox(
                                height: 200,
                                child: _buildStatusChart(),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Produtos Mais Utilizados',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                              const SizedBox(height: 16),
                              ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: _resultados['produtosMaisUtilizados'].length,
                                itemBuilder: (context, index) {
                                  final produto = _resultados['produtosMaisUtilizados'][index];
                                  return ListTile(
                                    title: Text(produto['nomeProduto']),
                                    subtitle: Text('${produto['quantidade']} unidades'),
                                    trailing: Text(
                                      formatoMoeda.format(produto['valorTotal']),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }

  Widget _buildFaturamentoChart() {
    if (_resultados['faturamentoPorSemana'] == null || _resultados['faturamentoPorSemana'].isEmpty) {
      return const Center(child: Text('Sem dados para exibir'));
    }

    final List<BarChartGroupData> barGroups = [];
    final List<dynamic> faturamentoPorSemana = _resultados['faturamentoPorSemana'];
    
    double maxY = 0;
    for (int i = 0; i < faturamentoPorSemana.length; i++) {
      final valor = faturamentoPorSemana[i]['valor'].toDouble();
      if (valor > maxY) maxY = valor;
      
      barGroups.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: valor,
              color: Colors.blue,
              width: 20,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(6),
                topRight: Radius.circular(6),
              ),
            ),
          ],
        ),
      );
    }

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: maxY * 1.2,
        barTouchData: BarTouchData(
          enabled: true,
          touchTooltipData: BarTouchTooltipData(
            tooltipBgColor: Colors.blueGrey,
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              final semana = faturamentoPorSemana[group.x];
              final valor = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$').format(semana['valor']);
              return BarTooltipItem(
                '${semana['periodo']}\n$valor',
                const TextStyle(color: Colors.white),
              );
            },
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                if (value >= 0 && value < faturamentoPorSemana.length) {
                  final semana = faturamentoPorSemana[value.toInt()]['periodo'];
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(semana.split(' ')[1]),
                  );
                }
                return const Text('');
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) {
                if (value == 0) return const Text('R\$0');
                if (value == maxY / 2) {
                  return Text(NumberFormat.compactCurrency(locale: 'pt_BR', symbol: 'R\$').format(value));
                }
                if (value == maxY) {
                  return Text(NumberFormat.compactCurrency(locale: 'pt_BR', symbol: 'R\$').format(value));
                }
                return const Text('');
              },
            ),
          ),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        gridData: FlGridData(
          show: true,
          horizontalInterval: maxY / 4,
        ),
        borderData: FlBorderData(show: false),
        barGroups: barGroups,
      ),
    );
  }

  Widget _buildStatusChart() {
    if (_resultados['servicosPorStatus'] == null || _resultados['servicosPorStatus'].isEmpty) {
      return const Center(child: Text('Sem dados para exibir'));
    }

    final Map<String, dynamic> servicosPorStatus = _resultados['servicosPorStatus'];
    final List<PieChartSectionData> sections = [];
    
    final colors = [Colors.blue, Colors.green, Colors.orange, Colors.red];
    int colorIndex = 0;
    
    servicosPorStatus.forEach((status, quantidade) {
      sections.add(
        PieChartSectionData(
          value: quantidade.toDouble(),
          title: '$status\n$quantidade',
          color: colors[colorIndex % colors.length],
          radius: 80,
          titleStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      );
      colorIndex++;
    });

    return PieChart(
      PieChartData(
        sections: sections,
        centerSpaceRadius: 40,
        sectionsSpace: 2,
      ),
    );
  }
}
