<div align="center">
  <img src="assets/images/e2e23485-820d-442e-a8b3-e63050ffda13.jpg" alt="YourFinance Logo" width="150" style="border-radius: 20px;">

  <h1>YourFinance</h1>
  <p><strong>A gestão do seu dinheiro tratada com a seriedade de um livro-razão. Imutável, auditável e no mais profundo Dark Mode.</strong></p>

  <!-- Badges -->
  <p>
    <img src="https://img.shields.io/badge/Flutter-3.x-02569B?style=for-the-badge&logo=flutter" alt="Flutter Version">
    <img src="https://img.shields.io/badge/Dart-3.x-0175C2?style=for-the-badge&logo=dart" alt="Dart Version">
    <img src="https://img.shields.io/badge/Platform-Android%20%7C%20iOS-lightgrey?style=for-the-badge" alt="Platforms">
    <img src="https://img.shields.io/badge/License-MIT-success?style=for-the-badge" alt="License">
    <img src="https://img.shields.io/github/repo-size/dhiogoFrutuoso/YourFinance?style=for-the-badge&color=9D00FF" alt="Repo Size">
  </p>

  <br />
  <a href="https://github.com/dhiogoFrutuoso/YourFinance/releases/latest/download/app-release.apk">
    <img src="https://img.shields.io/badge/Download_APK_Direto-000000?style=for-the-badge&logo=android&logoColor=9D00FF&color=121212&labelColor=000000" alt="Download APK" />
  </a>
</div>

<br />

![App Preview Placeholder](https://via.placeholder.com/1200x600/121212/9D00FF?text=YourFinance+App+Preview+Screenshots)

---

## 📑 Índice

- [Sobre o Projeto](#-sobre-o-projeto)
- [Principais Funcionalidades](#-principais-funcionalidades)
- [UI/UX & Design](#-uiux--design)
- [Stack Tecnológica](#-stack-tecnológica)
- [Instalação e Uso](#-instalação-e-uso)
- [Estrutura de Pastas](#-estrutura-de-pastas)
- [Contribuição](#-contribuição)
- [Licença](#-licença)

---

## 💡 Sobre o Projeto

O **YourFinance** não é apenas mais um aplicativo de controle de gastos. Ele é construído sobre o conceito de um *livro-razão contábil* — um ambiente seguro onde o histórico financeiro do usuário é imutável e sagrado. 

Nenhuma informação desaparece magicamente. Cada registro, estorno ou correção é mantido, garantindo que você tenha um **histórico 100% auditável**. Nenhuma ação destrutiva ocorre no aplicativo sem a explícita e obrigatória aprovação em um Modal de Confirmação, blindando seus dados contra acidentes.

Seu patrimônio exige respeito, e o YourFinance o trata de forma profissional com uma estética de elite.

---

## ✨ Principais Funcionalidades

O aplicativo é orquestrado em 5 pilares principais de navegação:

### 🗓️ Aba 1: Planejamento
O Setup mensal do seu dinheiro.
- **Projeção Mensal**: Defina suas entradas e despesas obrigatórias antecipadamente.
- **Sistema de Parcelas Inteligente**: Registre compras parceladas e o app gerenciará automaticamente as parcelas nos meses seguintes.
- **Data de Validade**: Determine vencimentos para despesas planejadas; se o prazo estourar, elas são desativadas de planejamentos futuros.

### 📊 Aba 2: Dashboard
Sua visão geral elegante e de impacto.
- **Gráficos de Rosca (Doughnut)**: Proporção cristalina entre receitas e despesas.
- **Visão Macro**: Cards gigantes de Saldo Atual, Entradas e Saídas filtráveis mês a mês.

### 📝 Aba 3: Registro e Auditoria
O coração do aplicativo: o Livro-Caixa.
- **Transações Dinâmicas**: Entradas e saídas categorizadas, com opção de estorno.
- **Filtros Chips Avançados**: Isole transações por Pix, Cartão de Crédito ou Dinheiro em um toque.
- **Vínculo Obrigatório**: Nenhuma despesa sai do seu bolso sem ser categorizada e explicada.

### 🎯 Aba 4: Status do Mês
Suas metas diárias gamificadas.
- **Checklist Interativo**: Suas despesas obrigatórias viram um checklist. Ao registrar o pagamento no Livro-Caixa, a conta recebe um *Check* automático.
- **Meta de Arrecadação**: Uma barra de progresso linear indicando quanto ainda falta entrar para cobrir seu custo de vida mínimo.

### 🧠 Aba 5: Inteligência Financeira (Tabelas)
Seu painel analítico pessoal de BI. Análises geradas automaticamente com base no seu uso:
- **Curva ABC**: Onde seu dinheiro está concentrado.
- **Projeção de Dívidas Futuras**: Quanto da sua renda dos próximos 3 meses já está comprometida.
- **Fator de Sobrevivência**: Uma métrica dura de *Custo de Vida Fixo* versus *Renda Fixa*.
- **Meios de Pagamento**: Diagnósticos comportamentais apontando excesso de uso de cartão de crédito.

---

## 🎨 UI/UX & Design

O YourFinance incorpora o exclusivo tema **"Roxo LED"**:

- **Dark Mode Profundo**: Utilizamos o preto absoluto (`#000000`) em fundos e cinzas extremamente escuros (`#121212`, `#1A1A1A`) em cards para maximizar o contraste.
- **Roxo Neon**: A cor de destaque (`#9D00FF`) cria uma estética *Cyber/LED*. Sombras projetadas (BoxShadow) geram um leve "glow" em botões primários e interações ativas.
- **Tipografia & Bordas**: Focamos na modernidade utilizando cantos arredondados suaves e fontes geométricas (Google Fonts), abandonando de vez qualquer visual genérico.

---

## 🛠️ Stack Tecnológica

- **Framework**: [Flutter](https://flutter.dev)
- **Linguagem**: Dart
- **Arquitetura**: Riverpod (State Management)
- **Armazenamento**: [Hive](https://pub.dev/packages/hive) (Solução robusta e super rápida em NoSQL para persistência local imutável).

---

## 🚀 Instalação e Uso

Pré-requisitos: Você precisa ter o [Flutter SDK](https://docs.flutter.dev/get-started/install) instalado na sua máquina.

1. **Clone o repositório:**
```bash
git clone https://github.com/dhiogoFrutuoso/YourFinance.git
```

2. **Navegue até o diretório do projeto:**
```bash
cd YourFinance
```

3. **Baixe as dependências do Flutter:**
```bash
flutter pub get
```

4. **Execute o projeto:**
*(Certifique-se de ter um emulador rodando ou dispositivo conectado)*
```bash
flutter run
```

---

## 📂 Estrutura de Pastas

O projeto adota uma arquitetura modular focada em escalabilidade:

```text
lib/
 ┣ models/        # Modelos de dados e entidades de domínio (PlanItem, Transaction)
 ┣ providers/     # Lógicas de estado e Riverpod Notifiers
 ┣ screens/       # As 5 telas (Abas) principais da interface gráfica
 ┣ services/      # Abstrações de serviços externos e Banco de Dados (HiveService)
 ┣ theme/         # Sistema de design (AppTheme, Cores LED)
 ┣ utils/         # Funções auxiliares (Formatadores de Moeda e Data)
 ┣ widgets/       # Componentes visuais genéricos (ex: ConfirmDialog)
 ┗ main.dart      # Ponto de entrada (Entrypoint)
```

---

## 🤝 Contribuição

Contribuições são bem-vindas e incentivadas para tornar o **YourFinance** ainda melhor. 
Para contribuir:

1. Faça um **Fork** do projeto.
2. Crie uma nova branch para a sua feature (`git checkout -b feature/MinhaNovaFeature`).
3. Commit suas alterações (`git commit -m 'Add: uma nova funcionalidade espetacular'`).
4. Faça o push para a branch (`git push origin feature/MinhaNovaFeature`).
5. Abra um **Pull Request**.

> [!WARNING]
> Certifique-se de respeitar o Design System "Roxo LED" e a regra máxima do app: nenhuma exclusão ou edição sem passar pela classe de Modal de Confirmação (`ConfirmDialog`).

---

## 📄 Licença

Distribuído sob a licença **MIT**. Veja o arquivo `LICENSE` para mais informações.

---
<div align="center">
  <sub>Desenvolvido com 💜 em Flutter.</sub>
</div>
