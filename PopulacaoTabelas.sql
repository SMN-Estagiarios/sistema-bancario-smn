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

INSERT INTO [dbo].[TaxaCartao]	(Id, Nome) VALUES
									(1, 'Anuidade'),
									(2, 'Multa'),
									(3, 'IOF');
GO

INSERT INTO [dbo].[ValorTaxaCartao]	(Id_TaxaCartao, Aliquota, DataInicial) VALUES
									(1, 0.0030, '2024-04-01'),
									(2, 0.0050, '2024-04-01'),
									(3, 0.0638, '2024-04-01');
GO

INSERT INTO [dbo].[StatusFatura]	(Id, Nome) VALUES 
									(1, 'Aberta'),
									(2, 'Fechada'),
									(3, 'Paga');
GO

INSERT INTO [dbo].[Taxa]	(Id, Nome) VALUES
							(1, 'TSN'),
							(2, 'IOF');
GO

INSERT INTO [dbo].[ValorTaxa]	(Id_Taxa, Aliquota, DataInicial) VALUES
								(1, 0.00200, '2024-03-01'),
								(2, 0.00380, '2024-04-01'),
								(1, 0.00400, '2024-03-15'),
								(1, 0.00600, '2024-04-01'),
								(1, 0.00800, '2024-04-15');

GO

INSERT INTO [dbo].[CreditScore]	(Id, Nome, Faixa, Aliquota) VALUES
								(1, 'Não elegível', -2000, 0),
								(2, 'Negativado', -200, 0.2),
								(3, 'Péssimo', 0, 0.4),
								(4, 'Ruim', 600, 0.6),
								(5, 'Mediano', 800, 0.8),
								(6, 'Bom', 1000, 1.2),
								(7, 'Ótimo', 1500, 1.4),
								(8, 'Excelente', 3000, 2.0);
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

INSERT INTO [dbo].[TaxaEmprestimo]	(Id, Nome) VALUES 
									(1, 'Padrão');

GO

INSERT INTO [dbo].[ValorTaxaEmprestimo]	(Id_TaxaEmprestimo, Id_CreditScore, Aliquota, DataInicial) VALUES 
										(1, 1, 0.070, '2024-04-01'),
										(1, 2, 0.065, '2024-04-01'),
										(1, 3, 0.060, '2024-04-01'),
										(1, 4, 0.055, '2024-04-01'),
										(1, 5, 0.050, '2024-04-01'),
										(1, 6, 0.047, '2024-04-01'),
										(1, 7, 0.045, '2024-04-01'),
										(1, 8, 0.040, '2024-04-01');

GO

INSERT INTO [dbo].[Tarifas] (Id, Nome) VALUES
							(1, 'PIX'),
							(2, 'DOC'),
							(3, 'TED'),
							(4, 'TAC'),
							(5, 'TMC');
GO

INSERT INTO [dbo].[PrecoTarifas]	(Id, Id_Tarifa, Valor, DataInicial) VALUES 
									(1, 1, 10, '01/04/2024'),
									(2, 2, 20, '01/04/2024'),
									(3, 3, 30, '01/04/2024'),
									(4, 4, 15, '01/04/2024'),
									(5, 5, 25,'01/04/2024');
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
									(9,'Juros'),
									(10,'Juros cheque especial'),
									(11,'Saque de cartao de credito')
GO