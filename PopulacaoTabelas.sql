USE SistemaBancario
GO 

INSERT INTO Correntista (Nome, Cpf, DataNasc, Contato, Email, Logradouro, Ativo) VALUES
						('Mozai', 98765432107, '1992/12/13', 988723360, 'mozai@mail.com', 'Rua da Aurora', 1),
						('Lutz', 03216549873, '1999/10/24', 987654321, 'lutz@mail.com', 'Avenida Minerva', 1),
						('Top Slyder', 14725836902, '1984/06/24', 991234568, 'slyder@mail.com', 'Rua da Areia', 1),
						('ovatsuG', 96385274100, '2001/04/24', 999582634, 'ovatsug@mail.com', 'Rua dos Ferreiros', 1),
						('Tails', 54623198726, '1988/04/27', 999888777, 'tails@mail.com', 'Rua da Thays', 1);
GO

INSERT INTO Contas	(Vlr_SldInicial, Vlr_Credito, Vlr_Debito, Dat_Saldo, Dat_Abertura, Ativo, Lim_ChequeEspecial, IdCorrentista) VALUES 
					(0.00, 0.00, 0.00, '2024-04-01', '2024-03-01', 1, 0.00, 1),
					(0.00, 0.00, 0.00, '2024-04-01', '2024-04-15', 1, 0.00, 2),
					(0.00, 0.00, 0.00, '2024-04-01', '2024-04-20', 1, 0.00, 3),
					(0.00, 0.00, 0.00, '2024-04-01', '2024-04-28', 1, 0.00, 4),
					(0.00, 0.00, 0.00, '2024-04-01', '2024-04-12', 1, 0.00, 5);
GO
-- INSERT DE TARIFAS COM VALORES FIXOS
INSERT INTO Tarifas (Id, Nome) VALUES
					(1, 'Pix'),
					(2, 'DOC'),
					(3, 'TED'),
					(5, 'TAC'),
					(6, 'TMC'),
					(7, 'TSN'),
					(8, 'TCC'),
					(9, 'TCD');

-- INSERT DE TARIFAS COM TAXA 
INSERT INTO PrecoTarifas (IdTarifa, Valor, Taxa, DataInicial) VALUES 
							(1, 10, NULL, '01/04/2024'),
							(2, 20, NULL, '01/04/2024'),
							(3, 30, NULL, '01/04/2024'),
							(5, 15, NULL, '01/04/2024'),
							(6,  25, NULL, '01/04/2024'),
							(7, NULL, 0.00334, '01/04/2024'),
							(8, 10, NULL, '01/04/2024'),
							(9, NULL, 0.0002, '01/04/2024');

GO

--INSERCAO DO ADMIN
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
