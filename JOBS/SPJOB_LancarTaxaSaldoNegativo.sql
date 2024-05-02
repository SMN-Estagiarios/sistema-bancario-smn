USE SistemaBancario
GO

CREATE OR ALTER PROCEDURE [dbo].[SPJOB_LancarTaxaSaldoNegativo]
	@Id_Conta INT = NULL,
	@DataPassada DATE = NULL
	AS
	/*
		DOCUMENTAÇÃO
		Arquivo fonte.....: SPJOB_LancarTaxaSaldoNegativo.sql
		Objetivo..........: Verificar diariamente quais as contas que estão negativas e lançar uma taxa de saldo nelas.
							Para o insert atribuimos diretamente o valor de Id_Usuario = 0 que é o equivalente ao ADMIN,
							Id_TipoLancamento = 9 que é o de juros, Id_Taxa = 1 que é o de taxa saldo negativo e Estorno = 0,
							que evidencia que não é um estorno.
		Autor.............: Orcino Neto, Odlavir Florentino e Pedro Avelino
		Data..............: 18/04/2024
		Ex................: BEGIN TRAN
								SELECT	Id,
										Id_Conta,
										Id_Usuario,
										Id_TipoLancamento,
										Tipo_Operacao,
										Vlr_Lanc,
										Nom_Historico,
										Dat_Lancamento,
										Estorno
									FROM [dbo].[Lancamentos] WITH(NOLOCK)

								DECLARE @Data_ini DATETIME = GETDATE(),
										@MesAnterior DATE;

								SET @MesAnterior = DATEADD(MONTH, -1, @Data_Ini);

								INSERT INTO [dbo].[SaldoDiario] (Id_Conta, Vlr_SldInicial, Vlr_SldFinal, Vlr_Credito, Vlr_Debito, Dat_Saldo) VALUES
																(2, 0, 100, 0, 0, DATEFROMPARTS(YEAR(@MesAnterior), MONTH(@MesAnterior), 5)),
																(1, 0, -100, 0, 0, DATEFROMPARTS(YEAR(@MesAnterior), MONTH(@MesAnterior), 10)),
																(1, 0, -500, 0, 0, DATEFROMPARTS(YEAR(@MesAnterior), MONTH(@MesAnterior), 11)),
																(2, 0, -1000, 0, 0, DATEFROMPARTS(YEAR(@MesAnterior), MONTH(@MesAnterior), 17));
			
								SELECT	Id_Conta,
										Saldo,
										Aliquota,
										Juros,
										DataSaldo
									FROM [dbo].[FNC_ListarSaldosEJurosDoMes]();
                                
								DBCC DROPCLEANBUFFERS
								DBCC FREEPROCCACHE
								DBCC FREESYSTEMCACHE ('ALL')

								EXEC [dbo].[SPJOB_LancarTaxaSaldoNegativo]

								SELECT DATEDIFF(MILLISECOND, @Data_ini, GETDATE()) AS TempoExecucao

								SELECT	Id,
										Id_Conta,
										Id_Usuario,
										Id_TipoLancamento,
										Tipo_Operacao,
										Vlr_Lanc,
										Nom_Historico,
										Dat_Lancamento,
										Estorno
									FROM [dbo].[Lancamentos] WITH(NOLOCK)
							ROLLBACK TRAN
	*/

	BEGIN

		DECLARE @DataAtual DATE = GETDATE();

		IF OBJECT_ID('tempdb..#Tabela') IS NOT NULL
			BEGIN
				DROP TABLE #Tabela;
			END
			
		CREATE TABLE #Tabela	(
									Id_Conta INT NOT NULL,
									Juros DECIMAL(15,2) NOT NULL
								)

		INSERT INTO #Tabela	(Id_Conta, Juros)
			SELECT	x.Id_Conta,
					SUM(x.Juros)
				FROM (SELECT	Id_Conta,
								Saldo,
								Aliquota,
								Juros,
								DataSaldo
						FROM [dbo].[FNC_ListarSaldosEJurosDoMes]()) x
				GROUP BY x.Id_Conta

		IF @@ERROR <> 0 OR @@ROWCOUNT = 0
		BEGIN
			RAISERROR('Não existe nehuma conta com o saldo negativo no mes', 16, 1)
		END

		-- Aplicar a taxa de saldo negativo para as mesmas
		INSERT INTO [dbo].[Lancamentos]	(Id_Conta, Id_Usuario, Id_TipoLancamento, Tipo_Operacao, Vlr_Lanc, Nom_Historico, Dat_Lancamento, Estorno)
			SELECT	Id_Conta,
					0,
					10,
					'D',
					Juros,
					'Valor REF sobre cobranças de limite cheque especial',
					@DataAtual,
					0
				FROM #Tabela;

		IF @@ERROR <> 0 OR @@ROWCOUNT = 0
		BEGIN
			RAISERROR('Erro ao lancar a taxa de saldo negativo', 16, 1)
		END
	END
GO