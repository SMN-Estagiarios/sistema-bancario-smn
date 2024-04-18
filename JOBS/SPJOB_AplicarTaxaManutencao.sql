CREATE OR ALTER PROCEDURE [dbo].[SPJOB_AplicarTaxaManutencao]
	AS
	/*
	Documentacao
	Arquivo Fonte........:	SPJOB_AplicarTaxaManutencao.sql
	Objetivo.............:	Aplica a Taxa de Manutencao de Conta a partir da data de abertura da conta nos meses subsequentes
	Autor................:	Olivio Freitas, Danyel Targino e Rafael Mauricio
	Data.................:	11/04/2024
	ObjetivoAlt..........:	N/A
	AutorAlt.............:	N/A
	DataAlt..............:	N/A
	Ex...................:	BEGIN TRAN
								DBCC DROPCLEANBUFFERS;
								DBCC FREEPROCCACHE;

								DECLARE @RET INT, 
										@Dat_init DATETIME = GETDATE()

								SELECT * FROM Contas ORDER BY Dat_Abertura DESC
								SELECT * FROM Lancamentos ORDER BY Dat_Lancamento DESC

								EXEC @RET = [dbo].[SPJOB_AplicarTaxaManutencao];

								SELECT	@RET AS RETORNO,
										DATEDIFF(MILLISECOND, @Dat_init, GETDATE()) AS TempoExecucao

								SELECT * FROM Lancamentos ORDER BY Dat_Lancamento DESC
								SELECT * FROM Contas ORDER BY Dat_Abertura DESC

							ROLLBACK TRAN
	*/
	IF EXISTS (SELECT TOP 1 1
					FROM [dbo].Contas
					WHERE DAY(Dat_Abertura) = DAY(GETDATE()))
		BEGIN
			-- Declarando variaveis
			DECLARE @Data_Atual DATE = GETDATE(),
					@Data_Abertura DATE,
					@Data_Cobranca INT,
					@Id_Conta INT,
					@Id_TarifaTMC INT,
					@Valor_TMC INT,
					@Nome_Tarifa VARCHAR(50),
					@Id_Admin INT = 1

			-- Capturar a data de abertura da conta
			BEGIN
				SELECT  @Data_Abertura = Dat_Abertura
					FROM [dbo].[Contas]
					WHERE Ativo = 1
			END

			-- Capturar Id_Taxa e Valor da Taxa
			SELECT	@Id_TarifaTMC = Id,
					@Valor_TMC = Valor,
					@Nome_Tarifa = Nome
				FROM [dbo].[Tarifas]
				WHERE Id = 6

			-- Comparar Mes/Ano Atual > DataAbertura Lancar @Data_Cobranca
			IF DATEDIFF(MONTH, @Data_Abertura, @Data_Atual) > 0
				BEGIN
					IF DAY(@Data_Abertura) <= 28
						BEGIN
							SET @Data_Cobranca = DAY(@Data_Abertura); 
						END
					ELSE
						SET @Data_Cobranca = DAY(EOMONTH(@Data_Atual));
				END

			-- Insert dos LANCAMENTOS
			INSERT INTO Lancamentos
				SELECT	Id, 
						@Id_Admin,
						@Id_TarifaTMC,
						'D',
						@Valor_TMC,
						@Nome_Tarifa,
						@Data_Atual,
						0
					FROM [dbo].[Contas]
					WHERE DAY(Dat_Abertura) = @Data_Cobranca
		END
GO