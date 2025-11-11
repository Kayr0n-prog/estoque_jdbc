package com.estoque.jdbc;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class DatabaseConfig {
    // ATENÇÃO: Substitua 'seu_usuario' e 'sua_senha' pelas credenciais do seu MySQL.
    // O banco de dados 'estoque_db' deve ser criado previamente.
    private static final String URL = "jdbc:mysql://localhost:3306/estoque_db?useSSL=false&serverTimezone=UTC";
    private static final String USER = "seu_usuario"; // MUDAR
    private static final String PASSWORD = "sua_senha"; // MUDAR

    public static Connection getConnection() throws SQLException {
        try {
            // Carrega o driver JDBC (opcional para versões recentes do JDBC, mas boa prática)
            Class.forName("com.mysql.cj.jdbc.Driver");
            return DriverManager.getConnection(URL, USER, PASSWORD);
        } catch (ClassNotFoundException e) {
            System.err.println("Driver JDBC do MySQL não encontrado.");
            throw new SQLException("Driver JDBC não encontrado", e);
        }
    }
}
