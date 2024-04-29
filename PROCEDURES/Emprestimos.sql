USE SistemaBancario
GO

CREATE OR ALTER PROCEDURE [dbo].[SP_RealizarEmprestimo] 
	@Id_Cta INT,
	@ValorSolicitado DECIMAL(15,2),
	@NumeroParcelas INT,
	@Tipo CHAR(3),
	@DataInicio DATE = NULL
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

									EXEC @Ret = [dbo].[SP_RealizarEmprestimo] 1, 1000, 2, 'PRE', NULL
									SELECT  Id_Conta,
											Id_StatusEmprestimo,
											Id_ValorTaxaEmprestimo,
											Id_Taxa,
											ValorSolicitado,
											ValorParcela,
											NumeroParcelas,
											Tipo,
											DataInicio
										FROM [dbo].[Emprestimo] WITH (NOLOCK)

									SELECT	@Ret AS Retorno,
											DATEDIFF(MILLISECOND, @Dat_ini, GETDATE()) AS ResultadoExecucao
								ROLLBACK TRAN

								-- RETORNO --
							
								00.................: Sucesso ao realizar um emprestimo
	*/
	BEGIN
		--Declarar variáveis
		DECLARE @DataAtual DATE = GETDATE(),
				@Id_Tarifa INT,
				@IdTaxaEmprestimo DECIMAL(5,4),
				@TaxaTotal DECIMAL(5,4),
				@PrecoParcela DECIMAL(6,2)
				
		-- Caso o parâmetro da primeira parcela for nulo, será passada para daqui a 1 mês e a data não poderá ser em um fim de semana
		SET @DataInicio = ISNULL(@DataInicio, DATEADD(MONTH, 1, @DataAtual))
		SET @DataInicio = CASE	WHEN DATENAME(WEEKDAY, @DataInicio) = 'Sábado' THEN DATEADD(DAY, 2, @DataInicio)
								WHEN DATENAME(WEEKDAY, @DataInicio) = 'Domingo' THEN DATEADD(DAY, 1, @DataInicio)
								ELSE @DataInicio
						  END

		-- Analisar se a data de início for maior que três meses ou anterior a data atual
		IF @DataInicio > DATEADD(MONTH, 3, @DataAtual) OR @DataInicio < @DataAtual
			BEGIN
				RAISERROR('A data do primeiro vencimento não está dentro do permitido', 16, 1)
			END
		-- Verificar se o valor solicitado está dentro do limite de três vezes o cheque especial
		IF @ValorSolicitado > 3 * (SELECT Lim_ChequeEspecial 
										FROM [dbo].[Contas] WITH(NOLOCK)
										WHERE Id = @Id_Cta
								  )
			BEGIN
				RAISERROR('O valor solicitado não está dentro do limite permitido', 16, 1)
			END 
		-- Verificar se a quantidade de parcelas está dentro do permitido
		IF NOT EXISTS (SELECT TOP 1 1
							FROM [dbo].[FNC_ListarParcelasEmprestimo]()
							WHERE QuantidadeParcela = @NumeroParcelas
					  )
			BEGIN
				RAISERROR('O número de parcelas não está dentro do limite permitido', 16, 1)
			END

		--Atribuir valor à TaxaEmprestimo
		SELECT @IdTaxaEmprestimo = vte.Id
			FROM [dbo].[Contas] c
				INNER JOIN [ValorTaxaEmprestimo] vte
					ON c.Id_CreditScore = vte.Id_CreditScore
			WHERE c.Id = @Id_Cta
		--Calcular TaxaTotal
		SELECT @TaxaTotal = [dbo].[FNC_CalcularTaxaEmprestimo](@Id_Cta)
		--Atribuir valor ao PrecoParcela
		SET @PrecoParcela = @ValorSolicitado * @TaxaTotal / (1 - POWER(1 + @TaxaTotal, - @NumeroParcelas))
		-- Criar o emprestimo
		INSERT INTO [dbo].[Emprestimo] (
											Id_Conta,
											Id_StatusEmprestimo,
											Id_ValorTaxaEmprestimo,
											Id_Taxa,
											ValorSolicitado,
											ValorParcela,
											NumeroParcelas,
											Tipo,
											DataInicio
										)
										VALUES
										(
											@Id_Cta,
											2,
											@IdTaxaEmprestimo,
											2,
											@ValorSolicitado,
											@PrecoParcela,
											@NumeroParcelas,
											@Tipo,
											@DataInicio
										)
		RETURN 0
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

								INSERT INTO [dbo].[Emprestimo]	(	
																	Id_Conta,
																	Id_StatusEmprestimo,
																	Id_ValorTaxaEmprestimo,
																	Id_Taxa,
																	ValorSolicitado,
																	ValorParcela,
																	NumeroParcelas,
																	Tipo,
																	DataInicio
																)
															VALUES
																(
																1,
																1,
																1,
																2,
																1000,
																100,
																10,
																'PRE',
																'2024-04-23'
																),
																(
																1,
																1,
																1,
																2,
																2000,
																400,
																5,
																'PRE',
																'2024-04-23'
																)

							

								EXEC [dbo].[SP_ListarEmprestimo] 1

								SELECT DATEDIFF(millisecond, @Dat_ini, GETDATE()) AS ResultadoExecucao
							ROLLBACK TRAN

								-- RETORNO --
							
								00.................:
	*/
	BEGIN
			BEGIN
				SELECT	Id_Conta,
						Id_StatusEmprestimo,
						Id_ValorTaxaEmprestimo,
						Id_Taxa,
						ValorSolicitado,
						ValorParcela,
						NumeroParcelas,
						Tipo,
						DataInicio
					FROM [dbo].[Emprestimo] WITH(NOLOCK)
					WHERE	Id_Conta = ISNULL(@IdConta, Id_Conta) AND
							DATEDIFF(DAY, DataInicio, ISNULL(@DataInicio, DataInicio)) = 0
			END
	END
GO

CREATE OR ALTER PROCEDURE [dbo].[SP_ListarSimulacaoEmprestimo] 
	@Id_Cta INT,
	@ValorSolicitado DECIMAL(15,2),
	@Parcela TINYINT = NULL
	AS
	/*
		Documentação
		Arquivo Fonte.........: Emprestimos.sql
		Objetivo..............: Listar uma simulação de empréstimo do valor passado como parâmetro. Será listado o valor
								das parcelas mensais e a quantidade das mesmas
		Autor.................: João Victor Maia, Odlavir Florentino, Rafael Maurício
		Data..................: 23/04/2024
		Ex....................: BEGIN TRAN
									DBCC FREEPROCCACHE
									DECLARE @Ret INT,
											@Dat_ini DATETIME = GETDATE()

									UPDATE [dbo].[Contas]
										SET Id_CreditScore = 1
										WHERE Id = 1

									EXEC @Ret = [dbo].[SP_ListarSimulacaoEmprestimo] 1, 1000
								
									SELECT	@Ret AS Retorno,
											DATEDIFF(MILLISECOND, @Dat_ini, GETDATE()) AS TempoExecucao
								ROLLBACK TRAN
	*/
	BEGIN
		--Declarar variáveis
		DECLARE @TaxaTotal DECIMAL(5,4)
		
		--Pegar TaxaTotal da Conta
		SELECT @TaxaTotal = [dbo].[FNC_CalcularTaxaEmprestimo](@Id_Cta)

		--Listar a simulação de empréstimo em que o valor da parcela seja maior que 100
		SELECT	QuantidadeParcela AS TotalParcelas,
				FORMAT(@ValorSolicitado * @TaxaTotal / (1 - POWER(1 + @TaxaTotal, - QuantidadeParcela)), 'C') AS PrecoParcela
			FROM [dbo].[FNC_ListarParcelasEmprestimo]()
			WHERE	@ValorSolicitado * @TaxaTotal / (1 - POWER(1 + @TaxaTotal, - QuantidadeParcela)) > 100
					AND QuantidadeParcela = ISNULL(@Parcela, QuantidadeParcela)
	END
GO