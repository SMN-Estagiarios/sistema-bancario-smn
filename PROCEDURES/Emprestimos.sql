USE SistemaBancario
GO

CREATE OR ALTER PROCEDURE [dbo].[SP_RealizarEmprestimo] @Id_Cta INT,
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

									DECLARE @Dat_init DATETIME = GETDATE()


									EXEC [dbo].[SP_RealizarEmprestimo] 1, 2000, 2, 'PRE', '2024-04-25'

									SELECT DATEDIFF(millisecond, @Dat_init, GETDATE()) AS ResultadoExecucao
								ROLLBACK TRAN

							-- RETORNO --
							
							00.................: Sucesso ao realizar um emprestimo.
							01.................: Erro, data informada excedeu o limite estipulado
							02.................: Erro, o valor é maior que o limite disponivel para emprestimo.
	*/
	BEGIN
		DECLARE @DataAtual DATE = GETDATE(),
				@Id_Tarifa INT;

		-- Analisar se a data foi passada na procedure
		IF @DataInicio IS NULL
			BEGIN
				-- Caso não tenha sido, utilizar a data atual
				SET @DataInicio = @DataAtual;
			END
		-- Analisar se a data passada foi maior que dois meses ou anterior a data atual
		ELSE IF @DataInicio >= DATEADD(MONTH, 2, @DataAtual) OR @DataInicio < @DataAtual
			BEGIN
				RETURN 1
			END
		ELSE
			BEGIN
				-- Verificar se o valor solicitado está dentro do limite de três vezes o cheque especial
				IF @ValorSolicitado <= 3 * (SELECT Lim_ChequeEspecial 
						  FROM [dbo].[Contas] WITH(NOLOCK)
						  WHERE Id = @Id_Cta)
					BEGIN
						-- Criar o emprestimo
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
															'*',
															@Id_Cta,
															@Id_Tarifa,
															@ValorSolicitado,
															FORMAT((@ValorSolicitado * POWER((1 + (SELECT Taxa
																											FROM PrecoTarifas WITH(NOLOCK)
																											WHERE Id = @Id_Tarifa)), @NumeroParcelas)) / @NumeroParcelas , 'C'),
															@NumeroParcelas,
															@Tipo,
															@DataInicio
														)
						RETURN 0
					END
				ELSE
					BEGIN
						RETURN 2
					END
			END
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

							DECLARE @Dat_init DATETIME = GETDATE()

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

CREATE OR ALTER PROCEDURE [dbo].[SP_ListarSimulacaoEmprestimo] @ValorEmprestimo DECIMAL(15,2)
	AS
	/*
	Documentação
	Arquivo Fonte.........: Emprestimos.sql
	Objetivo..............: Listar uma simulação de empréstimo do valor passado como parâmetro. Será listado o valor
							das parcelas mensais de 1 a 72 meses
	Autor.................: João Victor Maia, Odlavir Florentino, Rafael Maurício
	Data..................: 23/04/2024
	Ex....................: EXEC [dbo].[SP_ListarSimulacaoEmprestimo] 100
	*/
	BEGIN
		--Declarar variáveis
		DECLARE @Mes TINYINT = 1
		--Criar e popular tabela com a quantidade de parcelas de 1 a 72
		CREATE TABLE #QuantidadeParcela	(
										Quantidade TINYINT
									)
		WHILE @Mes <= 72
			BEGIN
				INSERT INTO #QuantidadeParcela VALUES(@Mes)
				SET @Mes += 1
			END
		--Listar a simulação de empréstimo
		SELECT	qm.Quantidade AS TotalParcelas,
				FORMAT((@ValorEmprestimo * POWER((1 + 0.07), qm.Quantidade)) / qm.Quantidade , 'C') AS PrecoParcela
			FROM #QuantidadeParcela qm
	END
GO