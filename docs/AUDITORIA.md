# YourFinance 1.4.0 — auditoria e evolução

Auditoria do código-fonte, modelos, persistência, navegação, telas, componentes compartilhados, configurações nativas e fluxo de publicação. Referência: descrição do Mobills fornecida pelo usuário. Nenhuma tela ou funcionalidade anterior foi eliminada; os indicadores detalhados continuam disponíveis em uma seção expansível no dashboard.

## Problemas encontrados e tratamento

| Área | Problema anterior | Resultado nesta versão |
|---|---|---|
| Dashboard e configurações | Logo PNG referenciada, mas somente WebP existia | Caminhos corrigidos |
| Planejamento | `isInstallment!` derrubava a tela com dados antigos nulos | Compatibilidade com registros antigos |
| Parcelas | Provider só carregava o mês de origem | Parcelas aparecem nos meses válidos; vencimento ajustado ao último dia do mês |
| Cópia mensal | Toques repetidos duplicavam itens e preservavam datas antigas | Cópia idempotente com datas ajustadas, sem duplicar parcelas já recorrentes |
| Dinheiro | Valores negativos, zero, NaN e formato brasileiro tratados incorretamente | Validação compartilhada e arredondamento a centavos |
| Estornos | Repetição permitida, sinais incorretos, vínculo com planejamento perdido | Bloqueio de repetição, sinais e vínculos preservados |
| Correções | Edição sobrescrevia um lançamento, contrariando o histórico auditável | Original + estorno + novo lançamento, com confirmação |
| Status e projeções | Pagamento parcial quitava obrigação; estorno não reabria pendência | Cálculo líquido compartilhado entre status, dashboard e projeção |
| Saldo | Transporte mensal confundido com receita e podia duplicar o patrimônio | Saldo acumulado calculado dos movimentos reais; transportes preservados no histórico e excluídos das análises |
| Extrato | Mês global ignorado; tipo e meio combinados com OR | Mês aplicado; filtros de dimensões diferentes combinados com AND |
| Backup | Apagava tudo antes de validar; caminho Android fixo | Arquivo validado antes da substituição, confirmação, recuperação local e seletor nativo de destino |
| Restauração | Cancelamento podia aparentar sucesso e exigia reinício | Cancelamento sem mensagem de sucesso; providers atualizados imediatamente |
| Segurança | Chave visual de biometria sem persistência ou bloqueio real | Preferência persistida, autenticação do sistema e bloqueio ao retornar do segundo plano |
| Android | Activity e temas não atendiam aos requisitos do local_auth | FragmentActivity, permissão e temas AppCompat |
| Aparência | Fonte dependia de download em execução; cards estouravam em telas pequenas | Inter incluída com licença, ajustes responsivos, diálogos roláveis e rótulos de ações |
| Release | Versão automática v1.0.x divergia do app; sem testes no fluxo | Versão única 1.4.0+12, análise/testes antes da build e publicação automática condicionada à mesma identidade de assinatura |

## Funcionalidades adicionadas

- Dashboard com resultado do mês, saldo acumulado, atalho para relatórios e indicadores existentes preservados.
- Comparativo de receitas e despesas em seis meses, com tabela textual equivalente ao gráfico.
- Rosca por categoria, detalhes dos lançamentos ao tocar na legenda ou no gráfico e cinco maiores gastos.
- Relatório por meio de pagamento e exportação CSV do período.
- Orçamentos gerais ou por categoria com alertas visuais de 80% e de limite excedido.
- Metas persistentes, valor reservado, prazo opcional e cálculo de aporte mensal; sem prazo, exibe o restante.
- Modais para criação, edição, detalhes e confirmação; ações rápidas de receita e despesa no cabeçalho.
- Categoria informada em lançamentos não vinculados e data de vencimento separada da validade do planejamento.
- Navegação entre meses e preferência persistida para ocultar valores.

## Critérios contábeis e compatibilidade

O app continua local, em BRL. Valores monetários mantêm o modelo `double` existente para compatibilidade; entradas novas são arredondadas para centavos. Novos estornos usam a data contábil do lançamento original e a data real da ação em `createdAt`; o modal informa isso. Estornos antigos não são reescritos. Em um mês com estorno de uma compra antiga, a despesa líquida pode ser negativa. A rosca exibe somente categorias positivas, enquanto o histórico e os totais preservam o efeito líquido.

Metas são acompanhamento manual de reservas e não movimentam o extrato. Orçamentos repetem o mesmo limite nos meses consultados; não têm histórico versionado de limites nem rollover automático. A previsão usa o planejamento registrado e não substitui o saldo disponível. Registros de transporte existentes permanecem no extrato por compatibilidade.

O backup JSON inclui planejamento, transações, orçamentos, metas e preferências visuais; a preferência de autenticação não é importada. Antes de restaurar, guarda uma cópia de recuperação local. A reversão automática cobre falhas reportadas durante a escrita; não é uma transação atômica entre caixas Hive em caso de interrupção do processo/energia. Arquivos locais não são criptografados por este app. A biometria é uma barreira de acesso à interface, não criptografia do banco.

## Verificação

- Testes automatizados de regras financeiras, persistência e compatibilidade de backup.
- Testes de renderização das seis telas em 375 × 812, interação com orçamentos/metas e detalhes por categoria.
- Dashboard em 844 × 390 com escala de texto ampliada e movimento reduzido.
- Capturas de telas geradas em `build/screenshots` e inspecionadas visualmente.
- Análise estática e build Android de release; resultados finais registrados nas notas da versão.

Não havia dispositivo Android ou emulador conectado. Autenticação biométrica real, diálogo nativo de arquivos, atualização sobre instalações antigas e TalkBack precisam de teste em aparelho. iOS, Windows, Linux, macOS e Web não foram compilados nesta entrega.

## Próximas melhorias por módulo

1. **Contas e cartões:** modelos próprios, saldo inicial por conta, transferências sem impacto no resultado, faturas/fechamento/limites e conciliação. O meio “cartão” atual continua sendo um atributo do lançamento, não uma fatura.
2. **Dados financeiros:** migração versionada para valores inteiros em centavos, restauração transacional, tratamento visível de registros corrompidos e backup criptografado. A leitura legada do Hive ainda ignora registros malformados; evitar sobrepor backups antigos sem conferência.
3. **Planejamento:** histórico de alterações, regras de recorrência além das parcelas mensais e geração com divisão do valor total entre parcelas. Atualmente o valor de um item parcelado é o valor de cada parcela.
4. **Categorias:** gerenciamento dedicado, subcategorias e fusão. O modelo CustomCategory existente foi preservado; os novos relatórios usam os snapshots de categoria das transações.
5. **Transações:** pendências independentes do planejamento, tags, anexos, ações em lote e notas separadas do título.
6. **Metas/orçamentos:** histórico de aportes, vínculo com contas, limites versionados por mês e alertas de notificação configuráveis.
7. **Relatórios:** PDF/XLSX, patrimônio líquido, investimentos e comparação anual. CSV já disponível.
8. **Integrações:** OFX/CSV com prévia e deduplicação, OCR, Open Finance, leitura de notificações/SMS e sincronização em nuvem dependem de projetos próprios, permissões e/ou serviços externos. Não há simulações desses serviços na interface.
9. **Acessibilidade e plataformas:** teste completo com TalkBack, escalas máximas em todas as telas, tema claro e navegação adaptativa para desktop/tablet.
10. **Distribuição:** migrar da assinatura de desenvolvimento legada para uma estratégia de assinatura de produção, considerando compatibilidade de atualizações e preservação de dados. Não substituir a chave sem um plano de migração.

## Skills

Aplicadas as skills locais `ponytail`, `frontend-design` e `ui-ux-pro-max`. Consultadas `find-skills` e `skill-installer`; instalada e aplicada `flutter-add-widget-test` do repositório oficial https://github.com/flutter/skills/tree/main/skills/flutter-add-widget-test. A seleção do catálogo de design foi ajustada à identidade roxa já existente; recomendações de landing page e fontes manuscritas não foram adotadas.

### Resultado final da distribuição

APK gerado: 1.4.0 (versionCode 12), applicationId `com.yourfinance.yourfinance`, Android mínimo 24. Assinatura verificada e idêntica à do APK anterior versionado no projeto. Não equivale a um teste de instalação em aparelho. O SHA-256 do arquivo acompanha o release em `SHA256SUMS.txt`.

Resultado das verificações: análise estática sem problemas, 23 testes passando e build Android de release concluída. O teste do fluxo completo também verifica o fechamento do formulário após terminar a gravação.
