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
										ValorJurosAtraso,
										Data_Cadastro
									FROM [dbo].[Parcela] WITH(NOLOCK)
								
								INSERT INTO [dbo].[ValorIndice]	(Id_Indice, Id_PeriodoIndice, Aliquota, DataInicio) VALUES 
										(1, 4, 1, '2024-07-01')

								EXEC [dbo].[SP_RealizarEmprestimo] 1, 1000, 2, 'PRE'
								EXEC [dbo].[SP_RealizarEmprestimo] 1, 1000, 24, 'POS', NULL, 1, 4
								EXEC [dbo].[SP_RealizarEmprestimo] 1, 5000, 5, 'POS', NULL, 1, 4


								EXEC [dbo].[SPJOB_AtualizarParcelasPos]

								SELECT Id,
										Id_Emprestimo,
										Id_Lancamento,
										Id_ValorIndice,
										Valor,
										ValorJurosAtraso,
										Data_Cadastro
									FROM [dbo].[Parcela] WITH(NOLOCK)
								ORDER BY Id_Emprestimo
							ROLLBACK TRAN
	*/
	BEGIN
		--DECLARE @DataAtual DATE = GETDATE();
		DECLARE @DataAtual DATE = '2024-11-01';

		-- Verificando se existe a tabela temporaria, se sim, excluir ela.
		IF OBJECT_ID('dbo..#Tabela') IS NOT NULL
			BEGIN
				DROP TABLE #Tabela;
			END

		-- Criando tabela temporaria
		CREATE TABLE #Tabela	(
									Id_Emprestimo INT,
									Valor_Solicitado DECIMAL(15,2),
									Numero_Parcelas INT,
									Id_Indice INT,
									Id_PeriodoIndice INT,
									Contagem_Parcela INT
								)

		INSERT INTO #Tabela	(
								Id_Emprestimo,
								Valor_Solicitado,
								Numero_Parcelas,
								Id_Indice,
								Id_PeriodoIndice,
								Contagem_Parcela
							)
			SELECT	P.Id_Emprestimo,
					E.ValorSolicitado,
					E.NumeroParcelas,
					E.Id_Indice,
					E.Id_PeriodoIndice,
					COUNT(P.Id_Emprestimo)
				FROM [dbo].[Parcela] P WITH(NOLOCK)
					INNER JOIN [dbo].[Emprestimo] E WITH(NOLOCK)
						ON P.Id_Emprestimo = E.Id
				GROUP BY P.Id_Emprestimo, E.NumeroParcelas, E.Id_Indice, E.Id_PeriodoIndice, E.ValorSolicitado
				HAVING	COUNT(P.Id_Emprestimo) < E.NumeroParcelas AND
						DATEDIFF(DAY, MAX(Data_Cadastro), @DataAtual) = 0

		WHILE EXISTS (SELECT TOP 1 1 FROM #Tabela)
			BEGIN
				DECLARE @Aliquota DECIMAL(6,5),
						@Valor_Parcela DECIMAL(15,2),
						@Valor_Solicitado DECIMAL(15,2),
						@Numero_Parcelas INT,
						@Id_PeriodoIndice INT,
						@Parcela_Incremento INT,
						@Parcela_While INT,
						@Contagem_Parcela INT = 1,
						@Data_Inicio DATE,
						@Id_Emprestimo INT,
						@Id_ValorIndice INT;

				SELECT TOP 1 @Data_Inicio = DATEADD(MONTH, Contagem_Parcela, DataInicio)
					FROM #Tabela T
						INNER JOIN [dbo].[Emprestimo] E WITH(NOLOCK)
							ON T.Id_Emprestimo = E.Id

				SELECT	TOP 1
								@Id_Emprestimo = Id_Emprestimo,
								@Valor_Solicitado = T.Valor_Solicitado,
								@Id_ValorIndice = VI.Id,
								@Id_PeriodoIndice = T.Id_PeriodoIndice,
								@Numero_Parcelas = T.Numero_Parcelas,
								@Aliquota = VI.Aliquota
					FROM #Tabela T
						INNER JOIN [dbo].[ValorIndice] VI WITH(NOLOCK)
							ON T.Id_Indice = VI.Id_Indice AND T.Id_PeriodoIndice = VI.Id_PeriodoIndice
					ORDER BY VI.DataInicio DESC

				SET @Valor_Parcela = (@Valor_Solicitado / @Numero_Parcelas) + (@Valor_Solicitado * @Aliquota)

				SET @Parcela_Incremento =	CASE WHEN @Id_PeriodoIndice = 1 THEN 1
												 WHEN @Id_PeriodoIndice = 2 THEN 2
												 WHEN @Id_PeriodoIndice = 3 THEN 3
												 WHEN @Id_PeriodoIndice = 4 THEN 6
												 WHEN @Id_PeriodoIndice = 5 THEN 12
										END

				IF @Parcela_Incremento < @Numero_Parcelas
					SET @Parcela_While = @Parcela_Incremento
				ELSE
					SET @Parcela_While = @Numero_Parcelas

				WHILE @Contagem_Parcela <= @Parcela_While
					BEGIN
						SET @Data_Inicio = DATEADD(MONTH, 1, @Data_Inicio)

						IF DAY(@Data_Inicio) > DAY(EOMONTH(@Data_Inicio))
							BEGIN
								SET @Data_Inicio = EOMONTH(@Data_Inicio)
							END

						INSERT INTO [DBO].[Parcela] (
														Id_Emprestimo,
														Id_Lancamento,
														Id_ValorIndice,
														Valor,
														ValorJurosAtraso,
														Data_Cadastro
													) VALUES (
																@Id_Emprestimo,
																NULL,
																@Id_ValorIndice,
																@Valor_Parcela,
																0.00,
																@Data_Inicio
															 )

						SET @Contagem_Parcela = @Contagem_Parcela + 1
					END

				DELETE #Tabela
					WHERE Id_Emprestimo =	(
												SELECT TOP 1 Id_Emprestimo
													FROM #Tabela
											)
			END
	END