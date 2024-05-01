USE SistemaBancario
GO

CREATE OR ALTER PROCEDURE [dbo].[SP_RealizarEmprestimo] 
	@Id_Cta INT,
	@ValorSolicitado DECIMAL(15,2),
	@NumeroParcelas INT,
	@Tipo CHAR(3),
	@DataInicio DATE = NULL,
	@TipoIndice INT = NULL,
	@PeriodoAtualizacao INT = NULL
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
											Id_ValorIndice,
											ValorSolicitado,
											NumeroParcelas,
											Tipo,
											DataInicio
										FROM [dbo].[Emprestimo] WITH (NOLOCK)

									SELECT	DATEDIFF(MILLISECOND, @Dat_ini, GETDATE()) AS ResultadoExecucao
								ROLLBACK TRAN

								-- RETORNO --
							
								00.................: Sucesso ao realizar um emprestimo
	*/
	BEGIN
		--Declarar variáveis
		DECLARE @DataAtual DATE = GETDATE(),
				@Id_Tarifa INT,
				@IdTaxaEmprestimo DECIMAL(5,4) = NULL,
				@TaxaTotal DECIMAL(5,4),
				@IdValorIndice INT = NULL;
				
		-- Caso o parâmetro da primeira parcela for nulo, será passada para daqui a 1 mês e a data não poderá ser em um fim de semana
		SET @DataInicio = ISNULL(@DataInicio, @DataAtual)
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

		IF @Tipo = 'PRE'
			BEGIN
				--Atribuir valor à TaxaEmprestimo
				SELECT @IdTaxaEmprestimo = vte.Id
					FROM [dbo].[Contas] c WITH(NOLOCK)
						INNER JOIN [ValorTaxaEmprestimo] vte WITH(NOLOCK)
							ON c.Id_CreditScore = vte.Id_CreditScore
					WHERE	c.Id = @Id_Cta AND
							vte.Id_TaxaEmprestimo = 1;
			END
		ELSE
			BEGIN
				-- Buscando o Valor Indice de acordo com o passado na procedure
				SELECT	TOP 1 @IdValorIndice = VI.Id
					FROM [dbo].[ValorIndice] VI WITH(NOLOCK) 
						INNER JOIN [dbo].[Indice] I WITH(NOLOCK)
							ON VI.Id_Indice = I.Id
						INNER JOIN [dbo].[PeriodoIndice] P WITH(NOLOCK)
							ON VI.Id_PeriodoIndice = P.Id
					WHERE	P.Id = @PeriodoAtualizacao AND
							I.Id = @TipoIndice
					ORDER BY VI.Id DESC;
			END

		-- Criando o emprestimo
		INSERT INTO [dbo].[Emprestimo]	(
											Id_Conta,
											Id_StatusEmprestimo,
											Id_ValorTaxaEmprestimo,
											Id_ValorIndice,
											ValorSolicitado,
											NumeroParcelas,
											Tipo,
											DataInicio
										) VALUES (
													@Id_Cta,
													2,
													@IdTaxaEmprestimo,
													@IdValorIndice,
													@ValorSolicitado,
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

								EXEC [dbo].[SP_RealizarEmprestimo] 1, 1000, 2, 'PRE', NULL
								--EXEC [dbo].[SP_RealizarEmprestimo] 2, 1000, 2, 'POS', NULL, 1, 1

								EXEC [dbo].[SP_ListarEmprestimo] 1
								EXEC [dbo].[SP_ListarEmprestimo] 

								SELECT DATEDIFF(millisecond, @Dat_ini, GETDATE()) AS ResultadoExecucao
							ROLLBACK TRAN

								-- RETORNO --
							
								00.................:
	*/
	BEGIN
			BEGIN
				SELECT	Id,
						Id_Conta,
						Id_StatusEmprestimo,
						Id_ValorTaxaEmprestimo,
						Id_ValorIndice,
						ValorSolicitado,
						NumeroParcelas,
						Tipo,
						DataInicio
					FROM [dbo].[Emprestimo] WITH(NOLOCK)
					WHERE	Id_Conta = ISNULL(@IdConta, Id_Conta) AND
							DATEDIFF(DAY, DataInicio, ISNULL(@DataInicio, DataInicio)) = 0
			END
	END
GO