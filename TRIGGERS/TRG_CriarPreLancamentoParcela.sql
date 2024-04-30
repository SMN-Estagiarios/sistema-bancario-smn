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
							SELECT	Id,
									Id_Conta,
									Id_StatusEmprestimo,
									Id_ValorTaxaEmprestimo,
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

							EXEC [dbo].[SP_RealizarEmprestimo] 1, 500, 5, 'PRE', NULL

							SELECT	Id,
									Id_Conta,
									Id_StatusEmprestimo,
									Id_ValorTaxaEmprestimo,
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
				@DataInicio DATE,
				@ContagemParcela INT = 1

		SELECT @Id = Id, 
			   @Id_Conta = Id_Conta,
			   @ValorSolicitado = ValorSolicitado,
			   @NumeroParcelas = NumeroParcelas,
			   @DataInicio = DataInicio
			FROM inserted

		SELECT @ValorParcela = PrecoParcela 
			FROM [dbo].[FNC_ListarSimulacaoEmprestimo](@Id_Conta, @ValorSolicitado)
			WHERE Parcelas = @NumeroParcelas
		
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