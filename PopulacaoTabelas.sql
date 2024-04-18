USE SistemaBancario
GO
INSERT INTO Contas	(Vlr_SldInicial, Vlr_Credito, Vlr_Debito, Dat_Saldo, Dat_Abertura, Ativo, Lim_ChequeEspecial) VALUES 
					(0.00, 0.00, 0.00, '2024-04-01', '2024-03-01', 1, 0.00),
					(0.00, 0.00, 0.00, '2024-04-01', '2024-04-15', 1, 0.00),
					(0.00, 0.00, 0.00, '2024-04-01', '2024-04-20', 1, 0.00),
					(0.00, 0.00, 0.00, '2024-04-01', '2024-04-28', 1, 0.00),
					(0.00, 0.00, 0.00, '2024-04-01', '2024-04-12', 1, 0.00);
GO
-- INSERT DE TARIFAS COM VALORES FIXOS
INSERT INTO Tarifas (Nome, Valor) VALUES 
					('Pix', 10),
					('DOC', 20),
					('TED', 30),
					('TEC', 0),
					('TAC', 15),
					('TMC', 25);

-- INSERT DE TARIFAS COM TAXA 
INSERT INTO Tarifas (Nome, Taxa) VALUES 
					('TSN', 0.00334);
GO


--INSER��O DO ADMIN
INSERT INTO Usuarios(Nom_Usuario) VALUES
					('ADM')
GO


INSERT INTO CreditScore (Nome, Faixa, Aliquota) VALUES
						('Não elegível', -2000, 0),
						('Negativado', 0, 0.2),
						('Péssimo', 400, 0.4),
						('Ruim', 600, 0.6),
						('Mediano', 800, 0.8),
						('Bom', 1000, 1),
						('Ótimo', 1500, 1.2),
						('Excelente', 3000, 2.0);
GO
