USE SistemaBancario
GO

CREATE OR ALTER PROCEDURE [dbo].[SP_RealizarEmprestimo] 
	@Id_Cta INT,
	@ValorSolicitado DECIMAL(15,2),
	@NumeroParcelas INT,
	@Tipo CHAR(3),
	@DataInicio DATE = NULL,
	@Id_Indice INT = NULL,
	@Id_PeriodoIndice INT = NULL
	AS
	/* 
			Documentação
			Arquivo Fonte.....: Emprestimos.sql
			Objetivo..........: Instancia para um emprestimo de um cliente
			Autor.............: Odlavir Florentino, Rafael Mauricio e João Victor
 			Data..............: 23/04/2024
			Ex................: BEGIN TRAN
									DBCC DROPCLEANBUFFERS;
									DBCC FREEPROCCACHE;
									
									DECLARE @Ret INT,
											@Dat_ini DATETIME = GETDATE()
											
									UPDATE [dbo].[Contas]
										SET Lim_ChequeEspecial = 2000,
											Id_CreditScore = 1
										WHERE Id = 1

									EXEC [dbo].[SP_RealizarEmprestimo] 1, 1000, 2, 'PRE'
									EXEC [dbo].[SP_RealizarEmprestimo] 1, 1000, 2, 'POS', NULL, 1, 1
									SELECT  Id,
											Id_Conta,
											Id_StatusEmprestimo,
											Id_ValorTaxaEmprestimo,
											Id_Indice,
											Id_PeriodoIndice,
											ValorSolicitado,
											NumeroParcelas,
											Tipo,
											DataInicio
										FROM [dbo].[Emprestimo] WITH (NOLOCK)

									SELECT	DATEDIFF(MILLISECOND, @Dat_ini, GETDATE()) AS ResultadoExecucao
								ROLLBACK TRAN

								-- RETORNO --
							
								00.................: Sucesso ao realizar um emprestimo
								01.................: Erro ao criar um emprestimo
								02.................: Erro ao criar um emprestimo, a data informada é maior que três meses ou menor que a atual
								03.................: Erro ao criar um emprestimo, o valor solicitado nao oestá dentro do limite permitido
								04.................: Erro ao criar um emprestimo, o número de parcelas nao está dentro do limite permitido
	*/
	BEGIN
		--Declarar variáveis
		DECLARE @DataAtual DATE = GETDATE(),
				@Id_Tarifa INT,
				@Id_ValorTaxaEmprestimo INT = NULL,
				@TaxaTotal DECIMAL(6, 5),
				@MultiplicadorLim INT;
				
		-- Caso o parâmetro da primeira parcela for nulo, será passada para daqui a 1 mês e a data não poderá ser em um fim de semana
		SET @DataInicio = ISNULL(@DataInicio, @DataAtual)
		SET @DataInicio = CASE	WHEN DATENAME(WEEKDAY, @DataInicio) = 'Sábado' THEN DATEADD(DAY, 2, @DataInicio)
								WHEN DATENAME(WEEKDAY, @DataInicio) = 'Domingo' THEN DATEADD(DAY, 1, @DataInicio)
								ELSE @DataInicio
						  END

		-- Analisar se a data de início for maior que três meses ou anterior a data atual
		IF @DataInicio > DATEADD(MONTH, 3, @DataAtual) OR @DataInicio < @DataAtual
			RETURN 2

		-- Verificar se o valor solicitado está dentro do limite de três vezes o cheque especial
		IF @ValorSolicitado > @MultiplicadorLim *	(
														SELECT Lim_ChequeEspecial 
															FROM [dbo].[Contas] WITH(NOLOCK)
															WHERE Id = @Id_Cta
													)
			RETURN 3
			
		-- Verificar se a quantidade de parcelas está dentro do permitido
		IF NOT EXISTS	(
							SELECT TOP 1 1
								FROM [dbo].[FNC_ListarParcelasEmprestimo]()
								WHERE QuantidadeParcela = @NumeroParcelas
						)
			RETURN 4

		IF @Tipo = 'PRE'
			BEGIN
				DECLARE @Id_CreditScore INT;

				--Atribuir valor à TaxaEmprestimo
				SELECT @Id_CreditScore = Id_CreditScore
					FROM [dbo].[Contas] WITH(NOLOCK)
					WHERE Id = @Id_Cta

				SELECT @Id_ValorTaxaEmprestimo = IdValorTaxaEmprestimo
					FROM [dbo].[FNC_ListarValorAtualTaxaEmprestimo](1, @Id_CreditScore)
			END

		-- Criando o emprestimo
		INSERT INTO [dbo].[Emprestimo]	(
											Id_Conta,
											Id_StatusEmprestimo,
											Id_ValorTaxaEmprestimo,
											Id_Indice,
											Id_PeriodoIndice,
											ValorSolicitado,
											NumeroParcelas,
											Tipo,
											DataInicio
										) VALUES	(
														@Id_Cta,
														2,
														@Id_ValorTaxaEmprestimo,
														@Id_Indice,
														@Id_PeriodoIndice,
														@ValorSolicitado,
														@NumeroParcelas,
														@Tipo,
														@DataInicio
													)
		IF @@ROWCOUNT <> 0
			RETURN 0
		ELSE
			RETURN 1
	END
GO

CREATE OR ALTER PROCEDURE [dbo].[SP_ListarEmprestimo]	@IdConta INT = NULL,
														@DataInicio DATE = NULL
	AS
	/*
		Documentação
		Arquivo Fonte.....: Emprestimos.sql
		Objetivo..........: Listar todas ou somente registros com os atributos de id ou data passados pelos parametros
		Autor.............: Odlavir Florentino, Rafael Mauricio, Joao Victor
		Data..............: 23/04/2024
		Ex................: BEGIN TRAN
								DBCC DROPCLEANBUFFERS;
								DBCC FREEPROCCACHE;

								DECLARE @Dat_ini DATETIME = GETDATE()

								UPDATE [dbo].[Contas]
									SET Id_CreditScore = 8,
										Lim_ChequeEspecial = 10000
									WHERE Id IN (1,2)

								EXEC [dbo].[SP_RealizarEmprestimo] 1, 1000, 2, 'PRE', NULL
								EXEC [dbo].[SP_RealizarEmprestimo] 2, 1000, 2, 'POS', NULL, 1, 1

								EXEC [dbo].[SP_ListarEmprestimo] 1
								EXEC [dbo].[SP_ListarEmprestimo] 

								SELECT DATEDIFF(MILLISECOND, @Dat_ini, GETDATE()) AS TempoExecucao
							ROLLBACK TRAN

								-- RETORNO --
							
								00.................: Valor retornado com sucesso
								01.................: Nenhum valor foi retornado
	*/
	BEGIN
		SELECT	Id,
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
			WHERE	Id_Conta = ISNULL(@IdConta, Id_Conta) AND
					DATEDIFF(DAY, DataInicio, ISNULL(@DataInicio, DataInicio)) = 0

		IF @@ROWCOUNT <> 0
			RETURN 0
		ELSE
			RETURN 1
	END
GO