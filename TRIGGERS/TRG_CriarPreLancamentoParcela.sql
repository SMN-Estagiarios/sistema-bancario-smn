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
									Id_ValorIndice,
									ValorSolicitado,
									NumeroParcelas,
									Tipo,
									DataInicio
								FROM [dbo].[Emprestimo] WITH(NOLOCK)

							SELECT	Id,
									Id_Emprestimo,
									Id_Lancamento,
									Valor,
									ValorJurosAtraso,
									Data_Cadastro
								FROM [dbo].[Parcela] WITH(NOLOCK)

							EXEC [dbo].[SP_RealizarEmprestimo] 1, 1000, 2, 'PRE'
							EXEC [dbo].[SP_RealizarEmprestimo] 1, 1000, 5, 'POS', NULL, 1, 1

							SELECT	Id
									Id_Conta,
									Id_StatusEmprestimo,
									Id_ValorTaxaEmprestimo,
									Id_ValorIndice,
									ValorSolicitado,
									NumeroParcelas,
									Tipo,
									DataInicio
								FROM [dbo].[Emprestimo] WITH(NOLOCK)

							SELECT	Id,
									Id_Emprestimo,
									Id_Lancamento,
									Valor,
									ValorJurosAtraso,
									Data_Cadastro
								FROM [dbo].[Parcela] WITH(NOLOCK)
						ROLLBACK TRAN
	*/
	BEGIN
		DECLARE @Id INT,
				@Id_Conta INT,
				@ValorSolicitado DECIMAL(15,2),
				@ValorParcela DECIMAL(15,2),
				@NumeroParcelas INT,
				@Id_ValorTaxaEmprestimo INT,
				@Id_ValorIndice INT,
				@DataInicio DATE,
				@ContagemParcela INT = 1,
				@Taxa DECIMAL(6,5)


		SELECT @Id = Id, 
			   @Id_Conta = Id_Conta,
			   @ValorSolicitado = ValorSolicitado,
			   @Id_ValorTaxaEmprestimo = Id_ValorTaxaEmprestimo,
			   @Id_ValorIndice = Id_ValorIndice,
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


		SELECT @ValorParcela = PrecoParcela 
			FROM #Tabela
			WHERE Parcelas = @NumeroParcelas

		IF @Id_ValorTaxaEmprestimo IS NOT NULL
			BEGIN
				WHILE @ContagemParcela <= @NumeroParcelas
					BEGIN
						SET @DataInicio = DATEADD(MONTH, 1, @DataInicio)

						IF DAY(@DataInicio) > DAY(EOMONTH(@DataInicio))	
							BEGIN
								SET @DataInicio = EOMONTH(@DataInicio)
							END

						INSERT INTO [DBO].[Parcela] (   Id_Emprestimo,
														Id_Lancamento,
														Valor,
														ValorJurosAtraso,
														Data_Cadastro
													) VALUES (
																@Id,
																NULL,
																@ValorParcela,
																0.00,
																@DataInicio
															 )

						SET @ContagemParcela = @ContagemParcela + 1
					END
			END
		ELSE IF @Id_ValorIndice IS NOT NULL
			BEGIN
				WHILE @ContagemParcela <= @NumeroParcelas
					BEGIN
						SET @DataInicio = DATEADD(MONTH, 1, @DataInicio)

						IF DAY(@DataInicio) > DAY(EOMONTH(@DataInicio))	
							BEGIN
								SET @DataInicio = EOMONTH(@DataInicio)
							END

						INSERT INTO [DBO].[Parcela] (   Id_Emprestimo,
														Id_Lancamento,
														Valor,
														ValorJurosAtraso,
														Data_Cadastro
													) VALUES (
																@Id,
																NULL,
																NULL,
																0.00,
																@DataInicio
																)

						SET @ContagemParcela = @ContagemParcela + 1
					END
			END
	END