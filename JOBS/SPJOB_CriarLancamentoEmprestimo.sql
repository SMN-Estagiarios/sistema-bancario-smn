CREATE OR ALTER PROCEDURE [dbo].[SPJOB_CriarLancamentoEmprestimo]
	AS
	/*
		Documenta��o
				Arquivo Fonte.....: SPJOB_CriarLancamentoEmprestimo.sql
				Objetivo..........: 
				Autor.............: Odlavir Florentino, Rafael Mauricio e Jo�o Victor
 				Data..............: 26/04/2024
				Ex................: BEGIN TRAN
										UPDATE [dbo].[Contas]
											SET Id_CreditScore = 1,
												Lim_ChequeEspecial = 5000
										WHERE Id = 1
										EXEC [dbo].[SP_RealizarEmprestimo] 1, 1000, 2, 'PRE', '2024-04-26'
										EXEC [dbo].[SPJOB_CriarLancamentoEmprestimo]
									ROLLBACK TRAN
	*/
	BEGIN
		--Declarar vari�veis
		DECLARE @DataAtual DATE = DATEADD(MONTH, 1, GETDATE())
		--Listar empr�stimos que est�o em aberto
		SELECT	Id,
				Id_Conta,
				Id_StatusEmprestimo,
				Id_ValorTaxaEmprestimo,
				Id_Taxa,
				ValorSolicitado,
				ValorParcela,
				NumeroParcelas,
				Tipo,
				DataInicio
			FROM [dbo].[Emprestimo] WITH(NOLOCK)
			WHERE	DataInicio < @DataAtual
					AND DATEPART(DAY, DataInicio) = DATEPART(DAY, @DataAtual)
					AND @DataAtual <= DATEADD(MONTH, NumeroParcelas - 1, DataInicio)

	END	
GO