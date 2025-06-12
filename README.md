# Service Core

![OS-Control]

**OS-Control** é um sistema inovador projetado para otimizar a gestão de atendimentos. A plataforma proporciona uma interface web para que administradores possam criar e gerenciar ordens de serviço de maneira eficiente. Além disso, disponibiliza um aplicativo móvel para que técnicos prestadores de serviço acessem, atualizem e finalizem ordens de serviço em tempo real, garantindo maior controle e agilidade no atendimento.

##  Tecnologias Utilizadas

- **Flutter: Framework para a criação da interface móvel.**
- **C#: Linguagem utilizada para a implementação da API e backend .NET**
- **Postgres SQL: Banco de Dados**

---

## 🚀 Funcionalidades

- 🔐 Tela de login com autenticação JWT
- 📄 Vizualização de resgistros da API
- 🧾 Listagem e manipulação das ordens de serviço
- 🧠 Gerenciamento de estado com BLoC

---

## Telas do projeto

![login](https://github.com/user-attachments/assets/e9432bff-2287-4777-b578-b57f398d5cdf)
![dashboard](https://github.com/user-attachments/assets/e1b8af1f-53a5-46b1-91b6-7890302c01b3)
![detalhes_ordem1](https://github.com/user-attachments/assets/82d2aeba-b5b5-4daa-8ed8-d39483a556ff)
![detalhes_ordem2](https://github.com/user-attachments/assets/61c087e4-096c-4370-90c5-2e9d392f3ced)

---

## 📁 Estrutura de Pastas

```
lib/
├── src/
│   ├── blocs/           # BLoC (Estado)
│   ├── models/          # Modelos (Dados)
│   ├── screens/         # Views (Interface)
│   ├── repository/      # Camada de dados
│   ├── services/        # Serviços (API)
│   └── router/          # Navegação
```

---

## 🧪 Como Rodar

1. Clone o repositório:

```bash
git clone https://github.com/pivetoo/sistemas-moveis.git
cd sistemas-moveis
```

2. Instale as dependências:

```bash
flutter pub get
```

3. Execute o app:

```bash
flutter run
```

---

## Alunos

- Rogerio Piveto | 1969034
- Pedro Nalom | 1968133
- Erik Zaros | 1959937
- Nicolas Basilio | 1967759
- Italo Gabriel | 1972431
