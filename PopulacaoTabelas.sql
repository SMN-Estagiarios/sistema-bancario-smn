USE SistemaBancario
GO 

--INSERCAO DO ADMIN
INSERT INTO [dbo].[Usuarios]	(Nom_Usuario) VALUES
								('ADM')
GO

INSERT INTO [dbo].[StatusCartaoCredito] (Id, Nome) VALUES 
										(1, 'Ativo'),
										(2, 'Inativo'),
										(3, 'Bloqueado');
GO

INSERT INTO [dbo].[StatusEmprestimo]	(Id, Nome) VALUES 
										(1, 'Analise'),
										(2, 'Aprovado'),
										(3, 'Negado');
GO

INSERT INTO [dbo].[TipoTransacao]	(Id, Nome) VALUES 
									(1, 'Compra'),
									(2, 'Saque'),
									(3, 'Pagamento');
GO

INSERT INTO [dbo].[StatusFatura]	(Id, Nome) VALUES 
									(1, 'Aberta'),
									(2, 'Fechada'),
									(3, 'Paga');
GO

INSERT INTO [dbo].[Correntista] (Nome, Cpf, DataNasc, Contato, Email, Logradouro, Ativo) VALUES
								('Mozai', 98765432107, '1992/12/13', 988723360, 'mozai@mail.com', 'Rua da Aurora', 1),
								('Lutz', 03216549873, '1999/10/24', 987654321, 'lutz@mail.com', 'Avenida Minerva', 1),
								('Top Slyder', 14725836902, '1984/06/24', 991234568, 'slyder@mail.com', 'Rua da Areia', 1),
								('ovatsuG', 96385274100, '2001/04/24', 999582634, 'ovatsug@mail.com', 'Rua dos Ferreiros', 1),
								('Tails', 54623198726, '1988/04/27', 999888777, 'tails@mail.com', 'Rua da Thays', 1);
GO

INSERT INTO [dbo].[Contas]	(Vlr_SldInicial, Vlr_Credito, Vlr_Debito, Dat_Saldo, Dat_Abertura, Ativo, Lim_ChequeEspecial, Id_Correntista) VALUES 
							(0.00, 0.00, 0.00, '2024-04-01', '2024-03-01', 1, 0.00, 1),
							(0.00, 0.00, 0.00, '2024-04-01', '2024-04-15', 1, 0.00, 2),
							(0.00, 0.00, 0.00, '2024-04-01', '2024-04-20', 1, 0.00, 3),
							(0.00, 0.00, 0.00, '2024-04-01', '2024-04-28', 1, 0.00, 4),
							(0.00, 0.00, 0.00, '2024-04-01', '2024-04-12', 1, 0.00, 5);
GO

INSERT INTO [dbo].[Tarifas] (Id, Nome) VALUES
							(1, 'Pix'),
							(2, 'DOC'),
							(3, 'TED'),
							(5, 'TAC'),
							(6, 'TMC');
GO

INSERT INTO [dbo].[PrecoTarifas]	(Id_Tarifa, Valor, DataInicial) VALUES 
									(1, 10, '01/04/2024'),
									(2, 20, '01/04/2024'),
									(3, 30, '01/04/2024'),
									(5, 15, '01/04/2024'),
									(6,  25,'01/04/2024');

GO

INSERT INTO [dbo].[Taxa]	(Id, Nome, Aliquota, DataInicial) VALUES
							(1, 'TSN', 0.00334, '01/04/2024');
GO

INSERT INTO [dbo].[CreditScore]	(Nome, Faixa, Aliquota) VALUES
								('Não elegível', -2000, 0),
								('Negativado', -200, 0.2),
								('Péssimo', 0, 0.4),
								('Ruim', 600, 0.6),
								('Mediano', 800, 0.8),
								('Bom', 1000, 1.2),
								('Ótimo', 1500, 1.4),
								('Excelente', 3000, 2.0);
GO

INSERT INTO [dbo].[TaxaEmprestimo]	(Id_CreditScore, Aliquota, NumeroParcelas, DataInicial) VALUES 
									(1, 0.010, 12, '2024-04-25'),
									(1, 0.015, 24, '2024-04-25');
GO

INSERT INTO [dbo].[TaxaCartao]	(Aliquota, DataInicial) VALUES 
								(0.0002, '01/04/2024');
GO

INSERT INTO [dbo].[TipoLancamento]	(Id, Nome) VALUES 
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
