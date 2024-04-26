USE SistemaBancario
GO

CREATE OR ALTER PROCEDURE [dbo].[SPJOB_CriarLancamentoEmprestimo]
	AS
	/*
		Documentação
				Arquivo Fonte.....: SPJOB_CriarLancamentoEmprestimo.sql
				Objetivo..........: Verificar se existe parcela a ser vencida e gerar um lancamento.
									Id_Usuario setado para 0, Id_TipoLancamento = 8.
				Autor.............: Odlavir Florentino, Rafael Mauricio e João Victor
 				Data..............: 26/04/2024
				Ex................: BEGIN TRAN
										SELECT * FROM Lancamentos
										UPDATE [dbo].[Contas]
											SET Id_CreditScore = 1,
												Lim_ChequeEspecial = 5000
										WHERE Id = 1
										EXEC [dbo].[SP_RealizarEmprestimo] 1, 1000, 2, 'PRE', '2024-04-26'
										EXEC [dbo].[SP_ListarSimulacaoEmprestimo] 1, 1000
										EXEC [dbo].[SPJOB_CriarLancamentoEmprestimo]

										SELECT * FROM Lancamentos
									ROLLBACK TRAN
	*/
	BEGIN
		--Declarar variáveis
		DECLARE @DataAtual DATE = GETDATE(),
				@DataProximoMes DATE;

		SET @DataProximoMes =  DATEADD(MONTH, 1, @DataAtual)

		--Listar empréstimos que estão em aberto

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
			WHERE	DataInicio < @DataProximoMes
					AND DATEPART(DAY, DataInicio) = DATEPART(DAY, @DataProximoMes)
					AND @DataProximoMes <= DATEADD(MONTH, NumeroParcelas - 1, DataInicio)


		INSERT INTO [dbo].[Lancamentos]	(	
											Id_Conta,
											Id_Usuario,
											Id_TipoLancamento,
											Tipo_Operacao,
											Vlr_Lanc,
											Nom_Historico,
											Dat_Lancamento,
											Estorno
										)
			SELECT	Id_Conta,
					0,
					8,
					'D',
					ValorParcela,
					'Teste',
					@DataAtual,
					0
			FROM [dbo].[Emprestimo] WITH(NOLOCK)
			WHERE	DataInicio < @DataProximoMes
					AND DATEPART(DAY, DataInicio) = DATEPART(DAY, @DataProximoMes)
					AND @DataProximoMes <= DATEADD(MONTH, NumeroParcelas - 1, DataInicio)
	END	
GO