CREATE OR ALTER PROCEDURE [dbo].[SPJOB_CriarLancamentoEmprestimo]
	AS
	/*
		Documentação
				Arquivo Fonte.....: SPJOB_CriarLancamentoEmprestimo.sql
				Objetivo..........: Verificar diariamente se existe parcela a ser vencida e gerar um lancamento.
									Id_Usuario fixo em 0 
									Id_TipoLancamento fixo em 8 (empréstimo)
				Autor.............: Odlavir Florentino, Rafael Mauricio e João Victor
 				Data..............: 26/04/2024
				Ex................: BEGIN TRAN
										DBCC FREEPROCCACHE
										DECLARE @Dat_ini DATETIME = GETDATE()
										SELECT TOP 10 *
											FROM Lancamentos
											ORDER BY Dat_Lancamento DESC

										UPDATE [dbo].[Contas]
											SET Id_CreditScore = 1,
												Lim_ChequeEspecial = 5000
										WHERE Id = 1
										
										EXEC [dbo].[SPJOB_CriarLancamentoEmprestimo]
										
										SELECT TOP 10 * 
											FROM Lancamentos
											ORDER BY Dat_Lancamento DESC

										SELECT DATEDIFF(MILLISECOND, @Dat_ini, GETDATE()) AS TempoExecucao
									ROLLBACK TRAN 
	*/ 
	BEGIN
		--Declarar variáveis
		DECLARE @DataAtual DATE = GETDATE()

		--Gerar lançamentos para empréstimos em aberto
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
									SELECT	e.Id_Conta,
											0,
											8,
											'D',
											(p.Valor + p.ValorJurosAtraso),
											'Empréstimo',
											@DataAtual,
											0
			FROM [dbo].[Emprestimo] e WITH(NOLOCK)
				INNER JOIN [dbo].[Parcela] p WITH(NOLOCK)
					ON p.Id_Emprestimo = e.Id
			WHERE	p.Data_Cadastro <= @DataAtual
					AND p.Id_Status = 2
	END	
GO