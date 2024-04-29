CREATE OR ALTER PROCEDURE [dbo].[SPJOB_FechamentoFatura]
	AS
	/*
		Documentação
		Arquivo fonte...: [dbo].[SPJOB_FechamentoFatura]
		Objetivo..........: Fechar fatura e abrir uma nova setando fatura para fechada.
		Autor..............: Isabella Siqueira, Olivio Freitas, Orcino Neto.
		Data...............: 29/04/2024
		EX..................:
								BEGIN TRAN
									DBCC DROPCLEANBUFFERS;
									DBCC FREEPROCCACHE;

									DECLARE @RET INT,
									@Dat_ini DATETIME = GETDATE();

									SELECT * FROM Fatura
									EXEC @RET=[dbo].[SPJOB_FechamentoFatura];

									SELECT * FROM Fatura

									SELECT @RET AS RETORNO,
									DATEDIFF(MILLISECOND, @Dat_ini, GETDATE()) AS TempoExecucao;								
								ROLLBACK TRAN
			Retornos:
			0-Sucesso
			1-Erro
	*/
	BEGIN
		--Criação da tabela temporaria para receber os Ids das faturas alteradas.
		CREATE TABLE #FaturasAlteradas(Id INT, Id_Conta INT)
		DECLARE @DataAtual DATE = GETDATE();

		-- Atualiza o status das faturas que atendem à condição
		UPDATE [dbo].[Fatura]
		SET Id_StatusFatura = 2
		OUTPUT inserted.Id, inserted.Id_Conta INTO #FaturasAlteradas
		WHERE DAY(DataVencimento) - 5 <= DAY(@DataAtual)
		AND MONTH(DataVencimento) = MONTH(@DataAtual)
		AND YEAR(DataVencimento) = YEAR(@DataAtual);

		-- Executa a stored procedure para gerar faturas com os IDs das faturas alteradas
		DECLARE @Id_Fatura INT,
					  @Id_Conta INT

		-- Loop para processar cada ID de fatura alterada
		WHILE EXISTS (SELECT 1 FROM #FaturasAlteradas)
			BEGIN
				SELECT @Id_Fatura = Id FROM #FaturasAlteradas;
				SELECT @Id_Conta = Id_Conta FROM #FaturasAlteradas;
				-- Executa a stored procedure para gerar a fatura para o ID atual
				EXEC [dbo].[SP_GerarFatura] @Id_Conta
				-- Remove o ID atual da tabela temporária
				DELETE FROM #FaturasAlteradas WHERE Id = @Id_Fatura;
			END
		DROP TABLE #FaturasAlteradas;
		IF @@ROWCOUNT <> 0
			RETURN 0
		ELSE
			RETURN 1
	END
GO