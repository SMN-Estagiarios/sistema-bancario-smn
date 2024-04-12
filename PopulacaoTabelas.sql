USE SistemaBancario
GO
INSERT INTO Contas(Vlr_SldInicial, Vlr_Credito, Vlr_Debito, Dat_Saldo, Dat_Abertura, Ativo, Lim_ChequeEspecial)
VALUES 
(0.00, 0.00, 0.00, '2024-04-12', '2024-04-12', 'S', 0.00),
(0.00, 0.00, 0.00, '2024-04-12', '2024-04-12', 'S', 0.00),
(0.00, 0.00, 0.00, '2024-04-12', '2024-04-12', 'S', 0.00),
(0.00, 0.00, 0.00, '2024-04-12', '2024-04-12', 'S', 0.00),
(0.00, 0.00, 0.00, '2024-04-12', '2024-04-12', 'S', 0.00);
GO
-- INSERT DE TARIFAS COM VALORES FIXOS
INSERT INTO Tarifas(Nome, Valor) VALUES 
('Pix', 10),
('DOC', 20),
('TED',30 ),
('TEC', 0),
('TAC', 15),
('TMC', 25);

-- INSERT DE TARIFAS COM TAXA 
INSERT INTO Tarifas(Nome, Taxa) VALUES 
('TSN', 0.00334);
GO

--INSERÇÃO DO ADMIN
INSERT INTO Usuarios VALUES('ADM')

