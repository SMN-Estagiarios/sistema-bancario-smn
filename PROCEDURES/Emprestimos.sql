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
										SET Lim_ChequeEspecial = 2000
										WHERE Id = 1

									EXEC @Ret = [dbo].[SP_RealizarEmprestimo] 1, 2000, 2, 'PRE', '2024-04-25'

									SELECT  Id,
											IdStatus,
											Id_Cta,
											Id_Tarifa,
											Valor,
											NumeroParcelas,
											Tipo,
											DataInicio
										FROM [dbo].[Emprestimos] WITH (NOLOCK)

									SELECT	@Ret AS Retorno,
											DATEDIFF(MILLISECOND, @Dat_ini, GETDATE()) AS ResultadoExecucao
								ROLLBACK TRAN

								-- RETORNO --
							
								00.................: Sucesso ao realizar um emprestimo
								01.................: Erro, data informada excedeu o limite estipulado de até 3 meses
								02.................: Erro, o valor é maior que o limite disponivel para emprestimo
								03.................: Erro, a quantidade de parcelas não está dentro do permitido
	*/
	BEGIN
		DECLARE @DataAtual DATE = GETDATE(),
				@Id_Tarifa INT;
				
		-- Caso o parâmetro da primeira parcela for nulo, será passada para daqui a 1 mês e a data não poderá ser em um fim de semana
		SET @DataInicio = ISNULL(@DataInicio, DATEADD(MONTH, 1, @DataAtual))
		SET @DataInicio = CASE	WHEN DATENAME(WEEKDAY, @DataInicio) = 'Sábado' THEN DATEADD(DAY, 2, @DataInicio)
								WHEN DATENAME(WEEKDAY, @DataInicio) = 'Domingo' THEN DATEADD(DAY, 1, @DataInicio)
								ELSE @DataInicio
						  END

		-- Analisar se a data de início for maior que três meses ou anterior a data atual
		IF @DataInicio > DATEADD(MONTH, 3, @DataAtual) OR @DataInicio < @DataAtual
			BEGIN
				RETURN 1
			END
		-- Verificar se o valor solicitado está dentro do limite de três vezes o cheque especial
		IF @ValorSolicitado > 3 * (SELECT Lim_ChequeEspecial 
										FROM [dbo].[Contas] WITH(NOLOCK)
										WHERE Id = @Id_Cta
								  )
			BEGIN
				RETURN 2
			END 
		-- Verificar se a quantidade de parcelas está dentro do permitido
		IF NOT EXISTS (SELECT TOP 1 1
							FROM [dbo].[FNC_ListarParcelasEmprestimo]()
							WHERE QuantidadeParcela = @NumeroParcelas
					  )
			BEGIN
				RETURN 3
			END
		-- Criar o emprestimo
		INSERT INTO [dbo].[Emprestimos] (	IdStatus,
											Id_Cta,
											Id_Tarifa,
											Valor,
											NumeroParcelas,
											Tipo, 
											DataInicio
										)
										VALUES
										(
											1,
											@Id_Cta,
											@Id_Tarifa,
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

								INSERT INTO [dbo].[StatusEmprestimos] (Id, Nome) VALUES (1, 'Em processamento')

								INSERT INTO [dbo].[Emprestimos] (	IdStatus,
																	Id_Cta,
																	Id_Tarifa,
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
																1000,
																100,
																10,
																'PRE',
																'2024-04-23'
																)

								INSERT INTO [dbo].[Emprestimos] (	IdStatus,
																	Id_Cta,
																	Id_Tarifa,
																	ValorSolicitado,
																	ValorParcela,
																	NumeroParcelas,
																	Tipo,
																	DataInicio
																)
															VALUES
																(
																1,
																2,
																1,
																1500,
																100,
																15,
																'PRE',
																'2024-04-25'
																)

							

								EXEC [dbo].[SP_ListarEmprestimo] 1

								SELECT DATEDIFF(millisecond, @Dat_init, GETDATE()) AS ResultadoExecucao

								TRUNCATE TABLE [dbo].[Emprestimos]
							ROLLBACK TRAN

								-- RETORNO --
							
								00.................:
	*/
	BEGIN
			BEGIN
				SELECT	Id,
						IdStatus,
						Id_Cta,
						Id_Tarifa,
						ValorSolicitado,
						ValorParcela,
						NumeroParcelas,
						Tipo,
						DataInicio
					FROM [dbo].[Emprestimos] WITH(NOLOCK)
					WHERE	Id_Cta = ISNULL(@IdConta, Id_Cta) AND
							DATEDIFF(DAY, DataInicio, ISNULL(@DataInicio, DataInicio)) = 0
			END
	END
GO

CREATE OR ALTER PROCEDURE [dbo].[SP_ListarSimulacaoEmprestimo] 
	@ValorEmprestimo DECIMAL(15,2)
	AS
	/*
		Documentação
		Arquivo Fonte.........: Emprestimos.sql
		Objetivo..............: Listar uma simulação de empréstimo do valor passado como parâmetro. Será listado o valor
								das parcelas mensais e a quantidade das mesmas
		Autor.................: João Victor Maia, Odlavir Florentino, Rafael Maurício
		Data..................: 23/04/2024
		Ex....................: DBCC FREEPROCCACHE
								DECLARE @Ret INT,
										@Dat_ini DATETIME = GETDATE()

								EXEC @Ret = [dbo].[SP_ListarSimulacaoEmprestimo] 1000

								SELECT	@Ret AS Retorno,
										DATEDIFF(MILLISECOND, @Dat_ini, GETDATE()) AS TempoExecucao
	*/
	BEGIN
		--Declarar variável da taxa sendo 7% de juros ao mês + IOF
		DECLARE @TaxaTotal DECIMAL(5,4) = 0.07 + 0.0038
		--Listar a simulação de empréstimo em que o valor da parcela seja maior que 100
		SELECT	QuantidadeParcela AS TotalParcelas,
				FORMAT(@ValorEmprestimo * @TaxaTotal / (1 - POWER(1 + @TaxaTotal, - QuantidadeParcela)), 'C') AS PrecoParcela
			FROM [dbo].[FNC_ListarParcelasEmprestimo]()
			WHERE @ValorEmprestimo * @TaxaTotal / (1 - POWER(1 + @TaxaTotal, - QuantidadeParcela)) > 100
	END
GO
