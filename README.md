# Sistema de Gerenciamento de Estoque com JDBC e MySQL

Este projeto demonstra a implementação de um sistema de gerenciamento de estoque complexo utilizando **Java (JDBC)** para a persistência de dados e **MySQL** como banco de dados.

O sistema inclui as operações **CRUD (Create, Read, Update, Delete)** completas para as principais entidades e implementa lógica de negócio de estoque através de transações e um `TRIGGER` no banco de dados.

## Estrutura do Projeto

O projeto foi estruturado utilizando **Maven** para gerenciamento de dependências.

- `src/main/java/com/estoque/jdbc/DatabaseConfig.java`: Configuração da conexão com o banco de dados. **(ATENÇÃO: As credenciais devem ser alteradas)**
- `src/main/java/com/estoque/jdbc/model/`: Classes POJO (Plain Old Java Objects) que representam as entidades do banco de dados.
- `src/main/java/com/estoque/jdbc/dao/`: Classes DAO (Data Access Object) que implementam as operações CRUD com JDBC.
- `src/main/java/com/estoque/jdbc/service/EstoqueService.java`: Camada de Serviço que encapsula a lógica de negócio e orquestra as operações dos DAOs.
- `src/main/java/com/estoque/jdbc/MainApp.java`: Classe principal que demonstra o uso das funcionalidades (CRUD e Transações de Estoque).

## Entidades Implementadas

1.  **Categoria**: CRUD completo.
2.  **Fornecedor**: CRUD completo.
3.  **Produto**: CRUD completo (com FKs para Categoria e Fornecedor).
4.  **Transacao**: CRUD completo. O `CREATE` desta entidade é a chave para a movimentação de estoque.
5.  **Estoque**: Tabela de consulta. A atualização da quantidade é feita automaticamente por um **Trigger** no MySQL, garantindo a integridade.

## Pré-requisitos

1.  **Java Development Kit (JDK)** 8 ou superior.
2.  **Apache Maven**.
3.  **Servidor MySQL** rodando.

## Configuração do Banco de Dados

1.  **Crie o banco de dados** e as tabelas utilizando o script `db_schema.sql`.
2.  **Altere as credenciais** de acesso no arquivo `src/main/java/com/estoque/jdbc/DatabaseConfig.java`.

```java
private static final String URL = "jdbc:mysql://localhost:3306/estoque_db?useSSL=false&serverTimezone=UTC";
private static final String USER = "seu_usuario"; // MUDAR
private static final String PASSWORD = "sua_senha"; // MUDAR
```

## Como Executar

1.  Navegue até a pasta raiz do projeto (`estoque_jdbc`).
2.  Compile o projeto:
    ```bash
    mvn clean install
    ```
3.  Execute a aplicação:
    ```bash
    mvn exec:java -Dexec.mainClass="com.estoque.jdbc.MainApp"
    ```

O `MainApp` irá tentar conectar ao banco e demonstrar as operações CRUD e a lógica de transação de estoque.
