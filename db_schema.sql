-- Criação do Banco de Dados
CREATE DATABASE IF NOT EXISTS estoque_db;
USE estoque_db;

-- Tabela Categoria
CREATE TABLE Categoria (
    id_categoria INT PRIMARY KEY AUTO_INCREMENT,
    nome VARCHAR(100) NOT NULL UNIQUE,
    descricao VARCHAR(255)
);

-- Tabela Fornecedor
CREATE TABLE Fornecedor (
    id_fornecedor INT PRIMARY KEY AUTO_INCREMENT,
    nome VARCHAR(100) NOT NULL UNIQUE,
    cnpj VARCHAR(18) UNIQUE,
    telefone VARCHAR(20),
    email VARCHAR(100)
);

-- Tabela Produto
CREATE TABLE Produto (
    id_produto INT PRIMARY KEY AUTO_INCREMENT,
    nome VARCHAR(100) NOT NULL UNIQUE,
    descricao TEXT,
    preco_custo DECIMAL(10, 2) NOT NULL,
    preco_venda DECIMAL(10, 2) NOT NULL,
    unidade_medida VARCHAR(10) NOT NULL, -- Ex: UN, KG, LT
    id_categoria INT,
    id_fornecedor INT,
    FOREIGN KEY (id_categoria) REFERENCES Categoria(id_categoria),
    FOREIGN KEY (id_fornecedor) REFERENCES Fornecedor(id_fornecedor)
);

-- Tabela Estoque (Armazena o saldo atual do produto)
CREATE TABLE Estoque (
    id_estoque INT PRIMARY KEY AUTO_INCREMENT,
    id_produto INT NOT NULL UNIQUE,
    quantidade INT NOT NULL DEFAULT 0,
    data_ultima_atualizacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (id_produto) REFERENCES Produto(id_produto)
);

-- Tabela Transacao (Registra as movimentações de estoque)
CREATE TABLE Transacao (
    id_transacao INT PRIMARY KEY AUTO_INCREMENT,
    id_produto INT NOT NULL,
    tipo ENUM('ENTRADA', 'SAIDA') NOT NULL,
    quantidade INT NOT NULL,
    data_transacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    observacao VARCHAR(255),
    FOREIGN KEY (id_produto) REFERENCES Produto(id_produto)
);

-- Índices para otimização de consultas
CREATE INDEX idx_produto_categoria ON Produto (id_categoria);
CREATE INDEX idx_produto_fornecedor ON Produto (id_fornecedor);
CREATE INDEX idx_transacao_produto ON Transacao (id_produto);

-- Gatilho (Trigger) para atualizar o Estoque automaticamente após uma Transacao
DELIMITER //
CREATE TRIGGER trg_atualiza_estoque
AFTER INSERT ON Transacao
FOR EACH ROW
BEGIN
    IF NEW.tipo = 'ENTRADA' THEN
        UPDATE Estoque
        SET quantidade = quantidade + NEW.quantidade
        WHERE id_produto = NEW.id_produto;
    ELSEIF NEW.tipo = 'SAIDA' THEN
        UPDATE Estoque
        SET quantidade = quantidade - NEW.quantidade
        WHERE id_produto = NEW.id_produto;
    END IF;
    
    -- Se o produto não existe na tabela Estoque, insere (apenas para ENTRADA)
    IF ROW_COUNT() = 0 AND NEW.tipo = 'ENTRADA' THEN
        INSERT INTO Estoque (id_produto, quantidade)
        VALUES (NEW.id_produto, NEW.quantidade);
    END IF;
END;
//
DELIMITER ;

-- Inserções de Exemplo (Opcional, para testes)
INSERT INTO Categoria (nome, descricao) VALUES ('Eletrônicos', 'Dispositivos eletrônicos e acessórios');
INSERT INTO Categoria (nome, descricao) VALUES ('Alimentos', 'Produtos alimentícios não perecíveis');

INSERT INTO Fornecedor (nome, cnpj, telefone, email) VALUES ('Tech Supplies Ltda', '11.111.111/0001-11', '5511987654321', 'contato@techsupplies.com');
INSERT INTO Fornecedor (nome, cnpj, telefone, email) VALUES ('Food Distr. S.A.', '22.222.222/0001-22', '5521912345678', 'vendas@fooddistr.com');

INSERT INTO Produto (nome, descricao, preco_custo, preco_venda, unidade_medida, id_categoria, id_fornecedor) 
VALUES ('Smartphone X', 'Modelo de última geração', 1500.00, 2500.00, 'UN', 1, 1);

INSERT INTO Produto (nome, descricao, preco_custo, preco_venda, unidade_medida, id_categoria, id_fornecedor) 
VALUES ('Arroz 5kg', 'Pacote de arroz branco', 10.00, 15.00, 'UN', 2, 2);

-- Exemplo de Transação (Entrada de 100 unidades de Smartphone X)
INSERT INTO Transacao (id_produto, tipo, quantidade, observacao) VALUES (1, 'ENTRADA', 100, 'Compra inicial');

-- Exemplo de Transação (Saída de 5 unidades de Arroz 5kg - Este produto não está no estoque ainda, o trigger não fará nada, mas a transação será registrada)
-- Para que a saída funcione corretamente, o produto deve ter estoque. Vamos adicionar estoque para o Arroz primeiro.
INSERT INTO Transacao (id_produto, tipo, quantidade, observacao) VALUES (2, 'ENTRADA', 50, 'Recebimento de carga');
INSERT INTO Transacao (id_produto, tipo, quantidade, observacao) VALUES (2, 'SAIDA', 5, 'Venda para cliente A');
