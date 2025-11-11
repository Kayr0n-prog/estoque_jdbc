package com.estoque.jdbc;

import java.sql.Connection;
import java.sql.SQLException;

public class MainApp {
    public static void main(String[] args) {
        System.out.println("Iniciando o Sistema de Gerenciamento de Estoque...");
        
        // Teste de conexão
        try (Connection connection = DatabaseConfig.getConnection()) {
            if (connection != null) {
                System.out.println("Conexão com o banco de dados estabelecida com sucesso!");
                // Aqui será a lógica principal do sistema
            } else {
                System.out.println("Falha ao estabelecer a conexão com o banco de dados.");
            }
        } catch (SQLException e) {
            System.err.println("Erro de SQL ao tentar conectar: " + e.getMessage());
            System.err.println("Verifique se o MySQL está rodando e se as credenciais em DatabaseConfig.java estão corretas.");
        }
    }
}
