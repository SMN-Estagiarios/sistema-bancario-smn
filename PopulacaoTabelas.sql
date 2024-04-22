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
INSERT INTO Tarifas (id, Nome, Valor, Dat_InicioValidade) VALUES
					(1,'Pix', 10, '01/04/2024'),
					(2,'DOC', 20, '01/04/2024'),
					(3,'TED', 30, '01/04/2024'),
					(4,'TEC', 0, '01/04/2024'),
					(5,'TAC', 15, '01/04/2024'),
					(6,'TMC', 25, '01/04/2024');

-- INSERT DE TARIFAS COM TAXA 
INSERT INTO Tarifas (id, Nome, Taxa, Dat_InicioValidade) VALUES 
					(7, 'TSN', 0.00334, '01/04/2024');
GO


--INSER��O DO ADMIN
INSERT INTO Usuarios(Nom_Usuario) VALUES
					('ADM')
GO


INSERT INTO CreditScore (Nome, Faixa, Aliquota) VALUES
						('Não elegível', -2000, 0),
						('Negativado', -200, 0.2),
						('Péssimo', 0, 0.4),
						('Ruim', 600, 0.6),
						('Mediano', 800, 0.8),
						('Bom', 1000, 1.2),
						('Ótimo', 1500, 1.4),
						('Excelente', 3000, 2.0);
GO

INSERT INTO TipoLancamento 	(Id, Nome) VALUES 
							(1,'Depósito'),
							(2,'Saque'),
							(3,'Transferência'),
							(4,'Pagamento'),
							(5,'Recebimento'),
							(6,'Tarifa'),
							(7,'Investimento'),
							(8,'Empréstimo'),
							(9,'Juros')
GO
