USE SistemaBancario
GO

CREATE OR ALTER PROCEDURE [dbo].[SP_ListarSimulacaoEmprestimo]
	@ValorEmprestimo DECIMAL(15,2)
	AS
	/*
	Documentação
	Arquivo Fonte.........: Emprestimos.sql
	Objetivo..............: Listar uma simulação de empréstimo do valor passado como parâmetro. Será listado o valor
							das parcelas mensais de 1 a 72 meses
	Autor.................: João Victor Maia, Odlavir Florentino, Rafael Maurício
	Data..................: 23/04/2024
	Ex....................: EXEC [dbo].[SP_ListarSimulacaoEmprestimo] 100
	*/
	BEGIN
		--Declarar variáveis
		DECLARE @Mes TINYINT = 1
		--Criar e popular tabela com a quantidade de parcelas de 1 a 72
		CREATE TABLE #QuantidadeParcela	(
										Quantidade TINYINT
									)
		WHILE @Mes <= 72
			BEGIN
				INSERT INTO #QuantidadeParcela VALUES(@Mes)
				SET @Mes += 1
			END
		--Listar a simulação de empréstimo
		SELECT	qm.Quantidade AS TotalParcelas,
				FORMAT((@ValorEmprestimo * POWER((1 + 0.06), qm.Quantidade)) / qm.Quantidade , 'C') AS PrecoParcela
			FROM #QuantidadeParcela qm
	END
GO

CREATE OR ALTER PROCEDURE [dbo].[SP_CriarEmprestimo]
	AS	
	/*
	Documentação
	Arquivo Fonte.........: Emprestimos.sql
	Objetivo..............: Criar um empréstimo para um cliente com o valor e a quantidade de parcelas dados no parâmetro
							Numero de parcelas fixo entre 1 e 72
	Autor.................: João Victor Maia, Odlavir Florentino, Rafael Maurício
	Data..................: 23/04/2024
	Ex....................: 
	*/
	BEGIN
		
	END