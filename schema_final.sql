-- Script de Criação da Estrutura do Banco de Dados para o Sistema de Estoque
-- Gerado automaticamente para o repositório: Kayr0n-prog/estoque_jdbc

-- 1. Criação do Banco de Dados
CREATE DATABASE IF NOT EXISTS estoque_db;
USE estoque_db;

-- 2. Tabela Categoria
-- Armazena as categorias dos produtos (ex: Eletrônicos, Alimentos)
CREATE TABLE IF NOT EXISTS Categoria (
    id_categoria INT PRIMARY KEY AUTO_INCREMENT,
    nome VARCHAR(100) NOT NULL UNIQUE,
    descricao VARCHAR(255)
);

-- 3. Tabela Fornecedor
-- Armazena os dados dos fornecedores dos produtos
CREATE TABLE IF NOT EXISTS Fornecedor (
    id_fornecedor INT PRIMARY KEY AUTO_INCREMENT,
    nome VARCHAR(100) NOT NULL UNIQUE,
    cnpj VARCHAR(18) UNIQUE,
    telefone VARCHAR(20),
    email VARCHAR(100)
);

-- 4. Tabela Produto
-- Armazena os detalhes dos produtos e vincula a categorias e fornecedores
CREATE TABLE IF NOT EXISTS Produto (
    id_produto INT PRIMARY KEY AUTO_INCREMENT,
    nome VARCHAR(100) NOT NULL UNIQUE,
    descricao TEXT,
    preco_custo DECIMAL(10, 2) NOT NULL,
    preco_venda DECIMAL(10, 2) NOT NULL,
    unidade_medida VARCHAR(10) NOT NULL, -- Ex: UN, KG, LT
    id_categoria INT,
    id_fornecedor INT,
    CONSTRAINT fk_produto_categoria FOREIGN KEY (id_categoria) REFERENCES Categoria(id_categoria) ON DELETE SET NULL,
    CONSTRAINT fk_produto_fornecedor FOREIGN KEY (id_fornecedor) REFERENCES Fornecedor(id_fornecedor) ON DELETE SET NULL
);

-- 5. Tabela Estoque
-- Armazena o saldo atual de cada produto em estoque
CREATE TABLE IF NOT EXISTS Estoque (
    id_estoque INT PRIMARY KEY AUTO_INCREMENT,
    id_produto INT NOT NULL UNIQUE,
    quantidade INT NOT NULL DEFAULT 0,
    data_ultima_atualizacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_estoque_produto FOREIGN KEY (id_produto) REFERENCES Produto(id_produto) ON DELETE CASCADE
);

-- 6. Tabela Transacao
-- Registra todas as movimentações (Entradas e Saídas) de estoque
CREATE TABLE IF NOT EXISTS Transacao (
    id_transacao INT PRIMARY KEY AUTO_INCREMENT,
    id_produto INT NOT NULL,
    tipo ENUM('ENTRADA', 'SAIDA') NOT NULL,
    quantidade INT NOT NULL,
    data_transacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    observacao VARCHAR(255),
    CONSTRAINT fk_transacao_produto FOREIGN KEY (id_produto) REFERENCES Produto(id_produto) ON DELETE CASCADE
);

-- 7. Índices para Otimização
-- Melhora a performance em consultas frequentes
CREATE INDEX idx_produto_categoria ON Produto (id_categoria);
CREATE INDEX idx_produto_fornecedor ON Produto (id_fornecedor);
CREATE INDEX idx_transacao_produto ON Transacao (id_produto);

-- 8. Gatilho (Trigger) para Atualização Automática de Estoque
-- Este trigger garante que o saldo na tabela 'Estoque' seja atualizado sempre que uma 'Transacao' for inserida.
DELIMITER //
CREATE TRIGGER trg_atualiza_estoque
AFTER INSERT ON Transacao
FOR EACH ROW
BEGIN
    -- Verifica se o produto já existe na tabela Estoque
    IF (SELECT COUNT(*) FROM Estoque WHERE id_produto = NEW.id_produto) = 0 THEN
        -- Se não existe e for uma ENTRADA, cria o registro inicial
        IF NEW.tipo = 'ENTRADA' THEN
            INSERT INTO Estoque (id_produto, quantidade)
            VALUES (NEW.id_produto, NEW.quantidade);
        END IF;
    ELSE
        -- Se já existe, atualiza a quantidade baseada no tipo de transação
        IF NEW.tipo = 'ENTRADA' THEN
            UPDATE Estoque
            SET quantidade = quantidade + NEW.quantidade
            WHERE id_produto = NEW.id_produto;
        ELSEIF NEW.tipo = 'SAIDA' THEN
            UPDATE Estoque
            SET quantidade = quantidade - NEW.quantidade
            WHERE id_produto = NEW.id_produto;
        END IF;
    END IF;
END;
//
DELIMITER ;

-- 9. Inserções de Exemplo (Opcional)
-- Descomente as linhas abaixo se desejar popular o banco com dados iniciais para teste.
/*
INSERT INTO Categoria (nome, descricao) VALUES ('Eletrônicos', 'Dispositivos eletrônicos e acessórios');
INSERT INTO Fornecedor (nome, cnpj, telefone, email) VALUES ('Tech Supplies Ltda', '11.111.111/0001-11', '5511987654321', 'contato@techsupplies.com');
INSERT INTO Produto (nome, descricao, preco_custo, preco_venda, unidade_medida, id_categoria, id_fornecedor) 
VALUES ('Smartphone X', 'Modelo de última geração', 1500.00, 2500.00, 'UN', 1, 1);
INSERT INTO Transacao (id_produto, tipo, quantidade, observacao) VALUES (1, 'ENTRADA', 10, 'Estoque inicial');
*/
