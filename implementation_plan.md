# Implementação: Enriquecimento de Dados e Correções

## Resumo
Esta refatoração irá corrigir as lógicas preditivas, melhorar a inteligência das modais adicionando um mini-extrato (Data Enrichment) e ajustar a linguagem e cores dos balões na linha do tempo.

## Proposed Changes

### Componente de Lógica Preditiva
#### [MODIFY] `lib/services/predictive_service.dart`
- Atualizar a função `calculateProjectedBalance` para garantir explicitamente que:
  - Entradas somam (+) e Despesas subtraem (-).
  - Incluir `PlanItemType.despesaVariavelObrigatoria` (atualmente ausente).
  - Certificar-se que "Entradas Previstas" não causem nenhum déficit matemático sob nenhuma condição temporal.

### Modais e UI
#### [MODIFY] `lib/widgets/timeline_widget.dart`
- Refatorar o widget do balão (Pin) no construtor de dias:
  - Cor baseada no tipo (Verde para entradas, Vermelho para despesas).
  - Cor baseada no status (Cinza se resolvido/pago).
  - Ícone interno e contador inteligente baseado nos itens.
- Refatorar `_showPredictiveModal`:
  - Adicionar um mini-extrato text-based detalhando o saldo (Saldo Atual, (+) Entradas, (-) Despesas, (=) Saldo Projetado).
  - Adicionar uma `ListView` dos eventos do dia especificado (Nome, Valor, e Status com ícone).

#### [MODIFY] `lib/screens/transactions_screen.dart`
- Adicionar um painel de contexto reativo abaixo do `NeonTextField` de Valor no `_AddTransactionSheet`.
- Para funcionar de forma reativa com o valor sendo digitado, criar um `ValueListenableBuilder` ou usar `setState` no `onChanged` do controlador.
- O painel exibirá o "Saldo Atual" e o "Saldo após pagamento/recebimento" subtraindo ou somando o valor digitado.
- Adicionalmente, se associado a um item do plano que é variável obrigatório (ex: Feira), calcular a cota restante.

#### [MODIFY] `lib/screens/planning_screen.dart`
- Corrigir a nomenclatura hardcoded no `_ItemCard`.
- Adicionar uma constante `isIncome` e aplicar operadores ternários no selo roxo e no subtítulo.
- "Recebimento: X/Y" vs "Vencimento: X/Y".

## User Review Required
> [!IMPORTANT]
> A implementação reativa na modal de transações utilizará um `ValueListenableBuilder` para o `_valueController` para evitar chamadas excessivas de setState que fechem a modal. Aceita essa abordagem arquitetural?

Por favor, aprove o plano ou informe se deseja ajustes antes de prosseguir.
