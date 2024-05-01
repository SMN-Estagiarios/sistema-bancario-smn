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
								INSERT INTO [dbo].[ValorIndice]	(Id_Indice, Id_PeriodoIndice, Aliquota, DataInicio) VALUES 
										(1, 4, 1, '2024-07-01')

								EXEC [dbo].[SP_RealizarEmprestimo] 1, 1000, 2, 'PRE'
								EXEC [dbo].[SP_RealizarEmprestimo] 1, 1000, 24, 'POS', NULL, 1, 4

								EXEC [dbo].[SPJOB_AtualizarParcelasPos]

								SELECT * FROM Parcela
							ROLLBACK TRAN
	*/
	BEGIN
		--DECLARE @DataAtual DATE = GETDATE();
		DECLARE @DataAtual DATE = '2024-11-01';

		-- Verificando se existe a tabela temporaria, se sim, dropar ela.
		IF OBJECT_ID('dbo..#Tabela') IS NOT NULL
			BEGIN
				DROP TABLE #Tabela;
			END

		-- Criando tabela temporaria
		CREATE TABLE #Tabela	(
									Id_Emprestimo INT,
									Valor_Solicitado DECIMAL(15,2),
									Numero_Parcelas INT,
									Id_ValorIndice INT,
									Contagem_Parcela INT
								)

		INSERT INTO #Tabela	(
								Id_Emprestimo,
								Valor_Solicitado,
								Numero_Parcelas,
								Id_ValorIndice,
								Contagem_Parcela
							)
			SELECT	P.Id_Emprestimo,
					E.ValorSolicitado,
					E.NumeroParcelas,
					E.Id_ValorIndice,
					COUNT(P.Id_Emprestimo)
				FROM [dbo].[Parcela] P WITH(NOLOCK)
					INNER JOIN [dbo].[Emprestimo] E WITH(NOLOCK)
						ON P.Id_Emprestimo = E.Id
				GROUP BY P.Id_Emprestimo, E.NumeroParcelas, E.Id_ValorIndice, E.ValorSolicitado
				HAVING	COUNT(P.Id_Emprestimo) < E.NumeroParcelas AND
						DATEDIFF(DAY, MAX(Data_Cadastro), @DataAtual) = 0

		WHILE EXISTS (SELECT TOP 1 1 FROM #Tabela)
			BEGIN
				DECLARE @ValorIndice DECIMAL(6,5),
						@ValorParcela DECIMAL(15,2),
						@ValorSolicitado DECIMAL(15,2),
						@NumeroParcelas INT,
						@Id_PeriodoIndice INT,
						@ParcelaIncremento INT,
						@ParcelaWhile INT,
						@ContagemParcela INT = 1,
						@DataInicio DATE,
						@IdEmprestimo INT

				SELECT TOP 1 @DataInicio = DATEADD(MONTH, Contagem_Parcela, DataInicio)
					FROM #Tabela T
						INNER JOIN [dbo].[Emprestimo] E WITH(NOLOCK)
							ON T.Id_Emprestimo = E.Id

				SELECT	TOP 1
								@IdEmprestimo = Id_Emprestimo,
								@ValorSolicitado = T.Valor_Solicitado,
								@NumeroParcelas = T.Numero_Parcelas,
								@Id_PeriodoIndice = VI.Id_PeriodoIndice,
								@ValorIndice = VI.Aliquota
					FROM #Tabela T
						INNER JOIN [dbo].[ValorIndice] VI WITH(NOLOCK)
							ON T.Id_ValorIndice = VI.Id

				SET @ValorParcela = (@ValorSolicitado / @NumeroParcelas) + (@ValorSolicitado * @ValorIndice)

				SET @ParcelaIncremento =	CASE WHEN @Id_PeriodoIndice = 1 THEN 1
												 WHEN @Id_PeriodoIndice = 2 THEN 2
												 WHEN @Id_PeriodoIndice = 3 THEN 3
												 WHEN @Id_PeriodoIndice = 4 THEN 6
												 WHEN @Id_PeriodoIndice = 5 THEN 12
										END

				IF @ParcelaIncremento < @NumeroParcelas
					SET @ParcelaWhile = @ParcelaIncremento
				ELSE
					SET @ParcelaWhile = @NumeroParcelas

				WHILE @ContagemParcela <= @ParcelaWhile
					BEGIN
						SET @DataInicio = DATEADD(MONTH, 1, @DataInicio)

						IF DAY(@DataInicio) > DAY(EOMONTH(@DataInicio))
							BEGIN
								SET @DataInicio = EOMONTH(@DataInicio)
							END

						INSERT INTO [DBO].[Parcela] (
														Id_Emprestimo,
														Id_Lancamento,
														Valor,
														ValorJurosAtraso,
														Data_Cadastro
													) VALUES (
																@IdEmprestimo,
																NULL,
																@ValorParcela,
																0.00,
																@DataInicio
															 )

						SET @ContagemParcela = @ContagemParcela + 1
					END

				DELETE #Tabela
					WHERE Id_Emprestimo =	(
												SELECT TOP 1 Id_Emprestimo
													FROM #Tabela
											)
			END
	END