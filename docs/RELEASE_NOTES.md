# YourFinance v1.4.1 — barra de abas sem sobreposição

- A barra inferior reserva espaço no layout e mantém as quatro abas acima dela, incluindo a área segura do dispositivo.
- Os botões de ação usam o espaço disponível acima da barra, sem deslocamento fixo de 90 pixels.
- Espaçamentos compensatórios reduzidos no dashboard e no status.
- Verificados os limites reais do conteúdo e dos botões nas quatro abas, em retrato e paisagem; o teste do fluxo completo também protege o limite do dashboard.

APK: versão 1.4.1, código 13. Mantida a assinatura anterior. Validação em aparelho físico continua pendente.

---

# Histórico: YourFinance v1.4.0 — visão financeira e confiabilidade

## Novidades

- Dashboard ampliado, com saldo acumulado, resultado do mês, valores ocultáveis e acesso rápido a lançamentos.
- Relatórios com comparativo de seis meses, despesas por categoria, detalhes interativos, meios de pagamento e maiores gastos.
- Exportação CSV, orçamentos por categoria e metas financeiras com prazo e aporte mensal.
- Modais de consulta, criação, edição e confirmação; todos os módulos anteriores preservados.
- Vencimentos no planejamento e categorias para lançamentos não planejados.

## Correções

- Parcelas visíveis nos meses seguintes e compatibilidade com dados antigos.
- Estornos sem duplicação, pagamentos parciais corretos e edição com preservação do histórico.
- Filtros do extrato e navegação mensal consistentes.
- Backup validado antes da restauração, cópia de recuperação local e atualização imediata da interface.
- Preferência de biometria/PIN persistida e bloqueio real pela autenticação do dispositivo.
- Logo corrigida, fonte incluída no APK, ajustes em telas pequenas e confirmações roláveis.

## Verificações e distribuição

- Flutter 3.44.3 / Dart 3.12.2.
- Análise estática sem problemas.
- 23 testes automatizados: regras financeiras, persistência, seis telas, modais, filtros e navegação completa.
- Capturas de telas revisadas em largura de 375 px; dashboard também verificado em paisagem e com texto ampliado.
- APK Android universal, versão 1.4.0, código 12. Confira a integridade com SHA256SUMS.txt.

A assinatura de desenvolvimento legada foi mantida. Este APK não representa uma configuração de assinatura de produção para Google Play. Não havia dispositivo Android/emulador disponível; biometria real, seletor de arquivos e atualização instalada ainda precisam de conferência em aparelho. Faça backup antes de atualizar; não desinstale o app caso queira preservar seus dados locais.

Os dados continuam locais. Open Finance, sincronização em nuvem, OCR, contas bancárias, faturas e investimentos completos não foram implementados nesta versão. O relatório de auditoria documenta os problemas corrigidos, limites e próximos passos em docs/AUDITORIA.md.
