USE SistemaBancario
GO

CREATE OR ALTER PROCEDURE [dbo].[SPJOB_AtualizarParcelasPos]
	AS
	/*
		Documentacao
		Arquivo Fonte.....: SPJOB_AtualizarParcelasPos.sql
		Objetivo..........: Analisar se existem parcelas nulas para serem atualizadas
		Autor.............: Joao Victor, Odlavir Florentino e Rafael Mauricio
		Data..............: 30/04/2024
		Ex................: BEGIN TRAN
								SELECT Id,
										Id_Emprestimo,
										Id_Lancamento,
										Id_ValorIndice,
										Valor,
										Juros,
										Data_Vencimento
									FROM [dbo].[Parcela] WITH(NOLOCK)
								
								INSERT INTO [dbo].[ValorIndice]	(Id_Indice, Id_PeriodoIndice, Aliquota, DataInicio) VALUES 
										(1, 4, 1, '2024-07-01')

								EXEC [dbo].[SP_RealizarEmprestimo] 1, 1000, 2, 'PRE'
								EXEC [dbo].[SP_RealizarEmprestimo] 1, 1000, 8, 'POS', NULL, 1, 4
								EXEC [dbo].[SP_RealizarEmprestimo] 1, 5000, 12, 'POS', NULL, 1, 4

								DECLARE @DATA_INI DATETIME = GETDATE(),
										@Ret INT;

								DBCC DROPCLEANBUFFERS
								DBCC FREEPROCCACHE
								DBCC FREESYSTEMCACHE ('ALL')

								EXEC @Ret = [dbo].[SPJOB_AtualizarParcelasPos]

								SELECT	@Ret AS Retorno,
										DATEDIFF(MILLISECOND, @DATA_INI, GETDATE()) AS ResultadoExecucao

								SELECT Id,
										Id_Emprestimo,
										Id_Lancamento,
										Id_ValorIndice,
										Valor,
										Juros,
										Data_Vencimento
									FROM [dbo].[Parcela] WITH(NOLOCK)
								ORDER BY Id_Emprestimo
							ROLLBACK TRAN

							-- Retornos --
							00: Parcelas lancadas com sucesso
							01: Não existe parcelas a serem lancadas
	*/
	BEGIN
		DECLARE @DataAtual DATE = GETDATE();

		-- Criando tabela temporaria
		CREATE TABLE #Tabela	(
									Id_Emprestimo INT,
									Valor_Solicitado DECIMAL(15,2),
									Numero_Parcelas INT,
									Id_Indice INT,
									Id_PeriodoIndice INT,
									Contagem_Parcela INT
								)

		/* Inserir registros na tabela temporaria, onde a contagem de parcelas existentes na tabela é menor que a quantidade de parcelas do emprestimo
		 e verificar se a data atual é igual ao da ultima parcela */
		INSERT INTO #Tabela	(
								Id_Emprestimo,
								Valor_Solicitado,
								Numero_Parcelas,
								Id_Indice,
								Id_PeriodoIndice,
								Contagem_Parcela
							)
			SELECT	p.Id_Emprestimo,
					e.ValorSolicitado,
					e.NumeroParcelas,
					e.Id_Indice,
					e.Id_PeriodoIndice,
					COUNT(P.Id_Emprestimo)
				FROM [dbo].[Parcela] p WITH(NOLOCK)
					INNER JOIN [dbo].[Emprestimo] e WITH(NOLOCK)
						ON p.Id_Emprestimo = e.Id
				GROUP BY p.Id_Emprestimo, e.NumeroParcelas, e.Id_Indice, e.Id_PeriodoIndice, e.ValorSolicitado
				HAVING	COUNT(p.Id_Emprestimo) < e.NumeroParcelas
						AND DATEDIFF(DAY, MAX(p.Data_Vencimento), @DataAtual) = 0

			IF @@ROWCOUNT = 0
				RETURN 1

		-- Enquanto existir registros na tabela temporaria, criar parcelas restantes
		WHILE EXISTS (SELECT TOP 1 1 FROM #Tabela)
			BEGIN
				-- Declarando variaveis
				DECLARE @Aliquota DECIMAL(6,5),
						@Valor_Parcela DECIMAL(15,2),
						@Valor_Solicitado DECIMAL(15,2),
						@Numero_Parcelas INT,
						@Numero_Parcelas_Restante INT,
						@Id_PeriodoIndice INT,
						@Parcela_Incremento INT,
						@Parcela_While INT,
						@Contagem_Parcela INT = 1,
						@Data_Inicio DATE,
						@Id_Emprestimo INT,
						@Id_ValorIndice INT,
						@Data_Vencimento DATE;

				-- Setar a data inicio de criacao das parcelas para um mes apos a ultima parcela lancada
				SELECT TOP 1 @Data_Inicio = DATEADD(MONTH, t.Contagem_Parcela, e.DataInicio)
					FROM #Tabela T
						INNER JOIN [dbo].[Emprestimo] e WITH(NOLOCK)
							ON t.Id_Emprestimo = e.Id

				-- Setando as variaveis com os valores da encontrados na tabela do ultimo valor indice lancado
				SELECT	TOP 1
								@Id_Emprestimo = t.Id_Emprestimo,
								@Valor_Solicitado = t.Valor_Solicitado,
								@Id_ValorIndice = vi.Id,
								@Id_PeriodoIndice = t.Id_PeriodoIndice,
								@Numero_Parcelas = t.Numero_Parcelas,
								@Numero_Parcelas_Restante = t.Numero_Parcelas - t.Contagem_Parcela,
								@Aliquota = vi.Aliquota
					FROM #Tabela t
						INNER JOIN [dbo].[ValorIndice] vi WITH(NOLOCK)
							ON t.Id_Indice = vi.Id_Indice AND t.Id_PeriodoIndice = vi.Id_PeriodoIndice
					ORDER BY vi.DataInicio DESC

				-- Calcular o valor da parcela de acordo com os novos valores de indice
				SET @Valor_Parcela = (@Valor_Solicitado / @Numero_Parcelas) + (@Valor_Solicitado * @Aliquota)

				-- Setar a variavel de acordo com o periodo de atualizacao do indice indicado no emprestimo
				SET @Parcela_Incremento =	CASE WHEN @Id_PeriodoIndice = 1 THEN 1
												 WHEN @Id_PeriodoIndice = 2 THEN 2
												 WHEN @Id_PeriodoIndice = 3 THEN 3
												 WHEN @Id_PeriodoIndice = 4 THEN 6
												 WHEN @Id_PeriodoIndice = 5 THEN 12
										END

				-- Verificar se o numero de parcela restante é maior que periodo de atualizacao do indice indicado no emprestimo
				IF @Parcela_Incremento < @Numero_Parcelas_Restante
					-- Setar a variavel do loop para a menor
					SET @Parcela_While = @Parcela_Incremento
				ELSE
					SET @Parcela_While = @Numero_Parcelas_Restante

				-- Gerar parcelas até a contagem atingir a quantidade da variavel do loop
				WHILE @Contagem_Parcela <= @Parcela_While
					BEGIN
						SET @Data_Vencimento = DATEADD(MONTH, @Contagem_Parcela, @Data_Inicio)

						IF DAY(@Data_Inicio) > DAY(EOMONTH(@Data_Vencimento))	
							BEGIN
								SET @Data_Vencimento = EOMONTH(@Data_Vencimento)
							END

						-- Inserir os registros das tabelas
						INSERT INTO [DBO].[Parcela] (
														Id_Emprestimo,
														Id_Lancamento,
														Id_ValorIndice,
														Valor,
														Juros,
														Data_Vencimento
													) VALUES (
																@Id_Emprestimo,
																NULL,
																@Id_ValorIndice,
																@Valor_Parcela,
																0.00,
																@Data_Vencimento
															 )

						SET @Contagem_Parcela = @Contagem_Parcela + 1
					END

				-- Deletar o primeiro registro da tabela
				DELETE #Tabela
					WHERE Id_Emprestimo =	(
												SELECT TOP 1 Id_Emprestimo
													FROM #Tabela
											)
			END
		RETURN 0
	END

