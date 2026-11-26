CREATE DATABASE IF NOT EXISTS atividades
    DEFAULT CHARACTER SET utf8mb4
    COLLATE utf8mb4_general_ci;

USE atividades;

CREATE TABLE IF NOT EXISTS atividades (
    id        INT AUTO_INCREMENT PRIMARY KEY,
    dia       DATE NOT NULL,
    atividade TEXT NOT NULL
);

INSERT INTO atividades (dia, atividade) VALUES ('2026-11-03', 'Prova de PHP');
INSERT INTO atividades (dia, atividade) VALUES ('2026-11-10', 'Aula de banco de dados');
INSERT INTO atividades (dia, atividade) VALUES ('2026-11-25', 'Estudar Dart');
INSERT INTO atividades (dia, atividade) VALUES ('2026-10-15', 'Trabalho de outubro');
