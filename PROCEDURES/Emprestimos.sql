USE SistemaBancario
GO

CREATE OR ALTER PROCEDURE [dbo].[SP_ListarSimulacaoEmprestimo]
	@ValorEmprestimo DECIMAL(15,2)
	AS
	/*
	Documenta��o
	Arquivo Fonte.........: Emprestimos.sql
	Objetivo..............: Listar uma simula��o de empr�stimo do valor passado como par�metro. Ser� listado o valor
							das parcelas mensais de 1 a 72 meses
	Autor.................: Jo�o Victor Maia, Odlavir Florentino, Rafael Maur�cio
	Data..................: 23/04/2024
	Ex....................: EXEC [dbo].[SP_ListarSimulacaoEmprestimo] 100
	*/
	BEGIN
		--Declarar vari�veis
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
		--Listar a simula��o de empr�stimo
		SELECT	qm.Quantidade AS TotalParcelas,
				FORMAT((@ValorEmprestimo * POWER((1 + 0.06), qm.Quantidade)) / qm.Quantidade , 'C') AS PrecoParcela
			FROM #QuantidadeParcela qm
	END
GO

CREATE OR ALTER PROCEDURE [dbo].[SP_CriarEmprestimo]
	AS	
	/*
	Documenta��o
	Arquivo Fonte.........: Emprestimos.sql
	Objetivo..............: Criar um empr�stimo para um cliente com o valor e a quantidade de parcelas dados no par�metro
							Numero de parcelas fixo entre 1 e 72
	Autor.................: Jo�o Victor Maia, Odlavir Florentino, Rafael Maur�cio
	Data..................: 23/04/2024
	Ex....................: 
	*/
	BEGIN
		
	END