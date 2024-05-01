USE SistemaBancario
GO
CREATE OR ALTER TRIGGER [DBO].[TRG_CriarPreLancamentoParcela]
	ON [DBO].[Emprestimo]
	AFTER INSERT
	AS
	/*
	Documentacao: 
	Arquivo Fonte.....: TRG_CriarPreLancamentoParcela.sql
	Objetivo..........: Criar as parcelas sempre que forem inseridos registros de emprestimo
	Autor.............: Joao Victor Maia, Odlavir Florentino, Rafael Mauricio
	Data..............: 29/04/2024
	Ex................: BEGIN TRAN
							SELECT	Id
									Id_Conta,
									Id_StatusEmprestimo,
									Id_ValorTaxaEmprestimo,
									Id_Indice,
									Id_PeriodoIndice,
									ValorSolicitado,
									NumeroParcelas,
									Tipo,
									DataInicio
								FROM [dbo].[Emprestimo] WITH(NOLOCK)

							SELECT	Id,
									Id_Emprestimo,
									Id_Lancamento,
									Id_ValorIndice,
									Valor,
									ValorJurosAtraso,
									Data_Cadastro
								FROM [dbo].[Parcela] WITH(NOLOCK)

							DECLARE @DATA_INI DATETIME = GETDATE();

							DBCC DROPCLEANBUFFERS
							DBCC FREEPROCCACHE
							DBCC FREESYSTEMCACHE ('ALL')

							EXEC [dbo].[SP_RealizarEmprestimo] 1, 1000, 2, 'PRE'
							EXEC [dbo].[SP_RealizarEmprestimo] 1, 2000, 24, 'POS', NULL, 1, 5

							
							SELECT	DATEDIFF(MILLISECOND, @DATA_INI, GETDATE()) AS ResultadoExecucao

							SELECT	Id
									Id_Conta,
									Id_StatusEmprestimo,
									Id_ValorTaxaEmprestimo,
									Id_Indice,
									Id_PeriodoIndice,
									ValorSolicitado,
									NumeroParcelas,
									Tipo,
									DataInicio
								FROM [dbo].[Emprestimo] WITH(NOLOCK)

							SELECT	Id,
									Id_Emprestimo,
									Id_Lancamento,
									Id_ValorIndice,
									Valor,
									ValorJurosAtraso,
									Data_Cadastro
								FROM [dbo].[Parcela] WITH(NOLOCK)
						ROLLBACK TRAN
	*/
	BEGIN
		-- Declarando variaveis necessarias
		DECLARE @Id_Emprestimo INT,
				@Id_Conta INT,
				@ValorSolicitado DECIMAL(15,2),
				@ValorParcela DECIMAL(15,2),
				@NumeroParcelas INT,
				@Id_ValorTaxaEmprestimo INT,
				@Id_Indice INT,
				@Id_PeriodoIndice INT,
				@DataInicio DATE,
				@ContagemParcela INT = 1,
				@Taxa DECIMAL(6,5),
				@Id_ValorIndice INT = NULL;

		-- Setando variaveis
		SELECT @Id_Emprestimo = Id, 
			   @Id_Conta = Id_Conta,
			   @ValorSolicitado = ValorSolicitado,
			   @Id_ValorTaxaEmprestimo = Id_ValorTaxaEmprestimo,
			   @Id_Indice = Id_Indice,
			   @Id_PeriodoIndice = Id_PeriodoIndice,
			   @NumeroParcelas = NumeroParcelas,
			   @DataInicio = DataInicio
			FROM inserted

		--Pegar Taxa da Conta
		SELECT @Taxa = [dbo].[FNC_CalcularTaxaEmprestimo](@Id_Conta)

		CREATE TABLE #Tabela	(
									Parcelas TINYINT,
									PrecoParcela DECIMAL(6,2)
								)

		--Listar a simulação de empréstimo em que o valor da parcela seja maior que 100
		INSERT INTO #Tabela 
			SELECT	QuantidadeParcela AS TotalParcelas,
					@ValorSolicitado * @Taxa / (1 - POWER(1 + @Taxa, - QuantidadeParcela)) AS PrecoParcela
			FROM [dbo].[FNC_ListarParcelasEmprestimo]()
			WHERE	@ValorSolicitado * @Taxa / (1 - POWER(1 + @Taxa, - QuantidadeParcela)) > 100

		-- Armazenar o valor da parcela de acordo com o numero de parcelas do emprestimo
		SELECT @ValorParcela = PrecoParcela 
			FROM #Tabela
			WHERE Parcelas = @NumeroParcelas

		-- Verificando se o tipo de emprestimo é Pre-fixado
		IF @Id_ValorTaxaEmprestimo IS NOT NULL
			BEGIN
				-- Gerando as parcelas
				WHILE @ContagemParcela <= @NumeroParcelas
					BEGIN
						SET @DataInicio = DATEADD(MONTH, 1, @DataInicio)

						IF DAY(@DataInicio) > DAY(EOMONTH(@DataInicio))	
							BEGIN
								SET @DataInicio = EOMONTH(@DataInicio)
							END

						-- Inserindo parcelas na tabela parcela
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
																@ValorParcela,
																0.00,
																@DataInicio
															 )

						SET @ContagemParcela = @ContagemParcela + 1
					END
			END
		ELSE IF @Id_PeriodoIndice IS NOT NULL AND @Id_Indice IS NOT NULL
			BEGIN
				-- Declarando variaveis necessarias para o tipo POS fixada
				DECLARE @Aliquota DECIMAL(6,5),
						@ParcelaIncremento INT,
						@ParcelaWhile INT

				-- Pegando o indice e aliquota mais recente
				SELECT TOP 1 
							@Id_ValorIndice = Id,
							@Aliquota = Aliquota
					FROM [dbo].[ValorIndice] WITH(NOLOCK)
					WHERE	Id_Indice = @Id_Indice AND
							Id_PeriodoIndice = @Id_PeriodoIndice AND
							DataInicio < = @DataInicio
					ORDER BY DataInicio DESC

				-- Setando o valor da parcela
				SET @ValorParcela = (@ValorSolicitado / @NumeroParcelas) + (@ValorSolicitado * @Aliquota)

				SET @ParcelaIncremento  =	CASE WHEN @Id_PeriodoIndice = 1 THEN 1
												 WHEN @Id_PeriodoIndice = 2 THEN 2
												 WHEN @Id_PeriodoIndice = 3 THEN 3
												 WHEN @Id_PeriodoIndice = 4 THEN 6
												 WHEN @Id_PeriodoIndice = 5 THEN 12
										END

				IF @ParcelaIncremento < @NumeroParcelas
					SET @ParcelaWhile = @ParcelaIncremento
				ELSE
					SET @ParcelaWhile = @NumeroParcelas

				-- Gerando parcelas
				WHILE @ContagemParcela <= @ParcelaWhile
					BEGIN
						SET @DataInicio = DATEADD(MONTH, 1, @DataInicio)

						IF DAY(@DataInicio) > DAY(EOMONTH(@DataInicio))
							BEGIN
								SET @DataInicio = EOMONTH(@DataInicio)
							END
						
						-- Inserindo parcela
						INSERT INTO [DBO].[Parcela] (   Id_Emprestimo,
														Id_Lancamento,
														Id_ValorIndice,
														Valor,
														ValorJurosAtraso,
														Data_Cadastro
													) VALUES (
																@Id_Emprestimo,
																NULL,
																@Id_ValorIndice,
																@ValorParcela,
																0.00,
																@DataInicio
															 )

						SET @ContagemParcela = @ContagemParcela + 1
					END
			END
	END