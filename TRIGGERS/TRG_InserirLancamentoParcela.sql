USE SistemaBancario
GO

CREATE OR ALTER TRIGGER [dbo].[TRG_InserirLancamentoParcela]
	ON [dbo].[Lancamentos]
	FOR INSERT
	AS
		/*
			Documentação
			Arquivo Fonte.........:	TRG_AtualizarParcela.sql
			Objetivo..............:	Atualizar o registro de parcela para popular a coluna do Id do lançamento
			Autor.................: Odlavir Florentino, Rafael Mauricio e João Victor
			Data..................: 29/04/2024
			Ex....................: BEGIN TRAN
										UPDATE [dbo].[Contas]
											SET Lim_ChequeEspecial = 3000,
												Id_CreditScore = 8
											WHERE Id = 1

										EXEC [dbo].[SP_RealizarEmprestimo] 1, 1000, 2, 'PRE'

										DECLARE @Id_Parcela INT

										SELECT TOP 1 @Id_Parcela = Id 
											FROM [dbo].[Parcela] WITH(NOLOCK)

										UPDATE [dbo].[Parcela]
											SET Data_Cadastro = GETDATE()
											WHERE Id = @Id_Parcela

										SELECT TOP 5 Id,
													 Id_Emprestimo,
													 Id_Lancamento,
													 Valor,
													 ValorJurosAtraso,
													 Data_Cadastro
											FROM [dbo].[Parcela] WITH(NOLOCK)
											WHERE	Id_Lancamento IS NULL
													AND Id_Emprestimo = (SELECT TOP 1 MAX(Id_Emprestimo)
																			FROM [dbo].[Parcela] WITH(NOLOCK))

										DECLARE @DATA_INI DATETIME = GETDATE();

										DBCC DROPCLEANBUFFERS
										DBCC FREEPROCCACHE
										DBCC FREESYSTEMCACHE ('ALL')

										EXEC [dbo].[SPJOB_LancarParcela]

										SELECT	DATEDIFF(MILLISECOND, @DATA_INI, GETDATE()) AS ResultadoExecucao

										SELECT TOP 5 Id,
													 Id_Emprestimo,
													 Id_Lancamento,
													 Valor,
													 ValorJurosAtraso,
													 Data_Cadastro
											FROM [dbo].[Parcela] WITH(NOLOCK)
											WHERE Id_Emprestimo = (SELECT TOP 1 MAX(Id_Emprestimo)
																		FROM [dbo].[Parcela] WITH(NOLOCK))
									ROLLBACK TRAN
		*/
	BEGIN
		DECLARE @Id_Lancamento INT, 
				@Tipo_Lancamento TINYINT,
				@Id_Emprestimo INT
		--Montar o cursor de lançamentos
		DECLARE Lancamento CURSOR FOR
			SELECT	i.Id,
					i.Id_TipoLancamento,
					e.Id
				FROM INSERTED i
					INNER JOIN [dbo].[Emprestimo] e WITH(NOLOCK)
						ON e.Id_Conta = i.Id_Conta
				ORDER BY i.Id ASC

		--Abrir o Cursor
		OPEN Lancamento

		--Pegar registro
		FETCH NEXT FROM Lancamento
			INTO @Id_Lancamento, @Tipo_Lancamento, @Id_Emprestimo

		--Loop no cursor
		WHILE @@FETCH_STATUS = 0
			BEGIN
				--Atualizar o Id do lançamento da parcela
				UPDATE TOP(1) [dbo].[Parcela]
					SET Id_Lancamento = @Id_Lancamento
					WHERE	Id_Lancamento IS NULL
							AND Id_Emprestimo = @Id_Emprestimo
				--Pegar próximo registro
				FETCH NEXT FROM Lancamento
					INTO @Id_Lancamento, @Tipo_Lancamento, @Id_Emprestimo
			END
		--Fechar cursor
		CLOSE Lancamento
		DEALLOCATE Lancamento
	END
GO

/*
criar no job de baixa de parcela um cursor pra pegar todas as parcelas candidatas a parcela
insere o lanc, pega o id e faz um updt na tabela de parcela com o id do launçamento
*/