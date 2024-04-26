USE SistemaBancario
GO

CREATE OR ALTER FUNCTION [dbo].[FNC_ListarSaldosEJurosDoMes]()
	RETURNS @SaldoNegativoMes TABLE	(
										Id_Conta INT NOT NULL,
										Saldo DECIMAL(15,2) NOT NULL,
										Aliquota DECIMAL(6,5) NOT NULL,
										Juros DECIMAL(15,2) NOT NULL,
										DataSaldo DATE NOT NULL
									)
	AS
	/*
		Documentacao
		Arquivo Fonte.....: FNC_ListarSaldosEJurosDoMes.sql
		Objetivo..........: Listar os todos os saldos do mes
		Autor.............: Odlavir Florentino
		Data..............: 26/04/2024
		EX................:	BEGIN TRAN
								DBCC FREEPROCCACHE
								DBCC DROPCLEANBUFFERS

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
									FROM [dbo].[FNC_ListarSaldosEJurosDoMes]()

								SELECT DATEDIFF(MILLISECOND, @Data_Ini, GETDATE()) AS TempoExecucao;
							ROLLBACK TRAN
	*/
	BEGIN
		-- Declarando variaveis de datas necessarias
		DECLARE @MesAnterior DATE = DATEADD(MONTH, -1, GETDATE()),
				@DataInicio DATE,
				@DataFim DATE;

		-- Setando para o inicio e fim do mes passado
		SET @DataInicio = DATEFROMPARTS(YEAR(@MesAnterior), MONTH(@MesAnterior), 1);
		SET @DataFim = DATEFROMPARTS(YEAR(@MesAnterior), MONTH(@MesAnterior), DAY(EOMONTH(@MesAnterior)));

		-- Inserindo na tabela todos os valores para atributos necessarios
		INSERT INTO @SaldoNegativoMes
			SELECT	x.Id_Conta AS Id_Conta,
					x.Saldo AS Saldo,
					x.Aliquota AS Aliquota,
					ABS(x.Saldo * Aliquota) AS Juros,
					x.Data_Saldo AS Data_Saldo
				FROM (SELECT	SD.Id_Conta AS Id_Conta,
								SD.Vlr_SldFinal AS Saldo,
								F.Aliquota AS Aliquota,
								SD.Dat_Saldo AS Data_Saldo
							FROM [dbo].[SaldoDiario] SD WITH(NOLOCK)
								CROSS APPLY [dbo].[FNC_IdentificarTaxaDoDia](1, SD.Dat_Saldo) F
							WHERE SD.Vlr_SldFinal < 0) x
				WHERE	x.Data_Saldo BETWEEN @DataInicio AND @DataFim
				ORDER BY x.Id_Conta, x.Data_Saldo
		RETURN
	END