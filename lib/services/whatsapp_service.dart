import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/servico_model.dart';

class WhatsAppService {
  static Future<void> enviarMensagemServico(BuildContext context, Servico servico) async {
    String telefone = servico.cliente.contato.replaceAll(RegExp(r'[^\d]'), '');
    final String nomeCliente = servico.cliente.nome;
    final String status = servico.status;
    final String dataEntrega = servico.dtEntrega.toLocal().toString().split(' ')[0];
    final String obs = servico.observacao?.trim().isNotEmpty == true
        ? servico.observacao!
        : "Sem observação";

    final double total = servico.produtos.fold(
      0.0,
          (soma, item) => soma + (item.quantidade * item.precoUnitario),
    );
    final itensFormatados = servico.produtos.map((item) {
      return "- ${item.quantidade}x ${item.produto.nome}-${item.observacao} (R\$ ${item.precoUnitario.toStringAsFixed(2)})";
    }).join('\n');

    final String mensagem = """
    Olá, $nomeCliente! 👋
    
    Aqui é da *Oficina da Moda* 💃🧵 e estamos passando pra te atualizar sobre o seu serviço (#${servico.id}).
    📌 Status: $status
    🗓️ Entrega: $dataEntrega
    📝 Observações: $obs
    📝 *Itens do serviço*:
    $itensFormatados
    
    💵 Total: R\$ ${total.toStringAsFixed(2)}
    
    Agradecemos por confiar no nosso trabalho ❤️
    Se precisar de algo, é só chamar por aqui mesmo!
    Esperamos te ver em breve com tudo prontinho 😉
    
    *Equipe Oficina da Moda*
    """;

    final mensagemCodificada = Uri.encodeComponent(mensagem.trimLeft());

    final url = Uri.parse("https://wa.me/55$telefone?text=$mensagemCodificada");

    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Não foi possível abrir o WhatsApp')),
      );
    }
  }

}
