CREATE OR ALTER PROCEDURE [dbo].[spjob_taxaManutencao]
	AS
	/*
	DOCUMENTA��O
	Arquivo Fonte........:	spjob_taxaManutencao.sql
	Objetivo.............:	Aplica a Taxa de Manuten��o de Conta a partir da data de abertura da conta nos meses subsequentes
	Autor................:	Ol�vio Freitas, Danyel Targino e Rafael Maur�cio
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

								EXEC @RET = [dbo].[spjob_taxaManutencao];

								SELECT @RET AS RETORNO,
								DATEDIFF(MILLISECOND, @Dat_init, GETDATE()) AS EXECU��O 

								SELECT * FROM Lancamentos ORDER BY Dat_Lancamento DESC
								SELECT * FROM Contas ORDER BY Dat_Abertura DESC

							ROLLBACK TRAN
	*/
	BEGIN
		-- Declarando vari�veis
		DECLARE @Data_Atual DATE = GETDATE(),
				@Data_Abertura DATE,
				@Data_Cobranca_TMC INT,
				@Data_Cobranca_TMC_FinalDoMes INT,
				@Id_Conta INT,
				@Id_TarifaTMC INT,
				@Valor_TMC INT

		-- Capturar a data de abertura da conta
			BEGIN
				SELECT  @Data_Abertura = Dat_Abertura
					FROM [dbo].[Contas]
					WHERE Ativo = 'S'
			END

		-- Capturar Id_Taxa e Valor da Taxa
			SELECT	@Id_TarifaTMC = Id,
					@Valor_TMC = Valor
				FROM Tarifas
				WHERE Nome = 'TMC'

		-- Comparar M�s/Ano Atual > DataAbertura Lan�ar @Data_Cobranca_TMC
			IF @Data_Abertura < @Data_Atual
				BEGIN
					IF DAY(@Data_Abertura) <= 28
						BEGIN
							SET @Data_Cobranca_TMC = DAY(@Data_Abertura)
						END
					ELSE
						BEGIN
							SET @Data_Cobranca_TMC_FinalDoMes = DAY(EOMONTH(@Data_Atual))
						END
				END

			-- Insert dos LAN�AMENTOS
			IF @Data_Cobranca_TMC IN (29, 30, 31) OR @Data_Cobranca_TMC_FinalDoMes IN (29, 30, 31)
				BEGIN
					INSERT INTO Lancamentos
						SELECT	Id, 
								1,
								@Id_TarifaTMC,
								'D',
								@Valor_TMC,
								'TMC',
								@Data_Atual
							FROM [dbo].[Contas]
							WHERE DAY(Dat_Abertura) = @Data_Cobranca_TMC_FinalDoMes
				END
			ELSE
				BEGIN
					INSERT INTO Lancamentos
						SELECT	Id, 
								1,
								@Id_TarifaTMC,
								'D',
								@Valor_TMC,
								'TMC',
								@Data_Atual
							FROM [dbo].[Contas]
							WHERE DAY(Dat_Abertura) = @Data_Cobranca_TMC
				END
	END
GO