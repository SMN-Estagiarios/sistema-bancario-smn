USE SistemaBancario
GO

CREATE OR ALTER PROCEDURE [dbo].[SPJOB_AplicarTaxaManutencao]
	AS
	/*
	Documentacao
	Arquivo Fonte........:	SPJOB_AplicarTaxaManutencao.sql
	Objetivo.............:	Aplica a Taxa de Manutencao de Conta a partir da data de abertura da conta nos meses subsequentes
                            Id_Usuario o valor é 0, pois é usuario do sistema
                            Id_TipoLancamento o valor é 6, pois refere-se a Tarifa
							Id_Tarifa o valor é 6, pois refere-se a Taxa de Manutencao de Conta (TMC)
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
					FROM [dbo].[Contas]
					WHERE DAY(Dat_Abertura) = DAY(GETDATE()))
		BEGIN
			-- Declarando variaveis
			DECLARE @Data_Atual DATE = GETDATE(),
					@Data_Abertura DATE,
					@Data_Cobranca INT,
					@Id_Conta INT,
					@Valor_TMC INT,
					@Nome_Tarifa VARCHAR(50)


			-- Capturar a data de abertura da conta
			BEGIN
				SELECT  @Data_Abertura = Dat_Abertura
					FROM [dbo].[Contas] WITH(NOLOCK)
					WHERE Ativo = 1
						AND DAY(Dat_Abertura) = DAY(GETDATE())
			END

			-- Capturar Id_Taxa e Valor da Taxa
			SELECT	@Valor_TMC = PT.Valor,
					@Nome_Tarifa = T.Nome
				FROM [dbo].[Tarifas] T WITH(NOLOCK)
					INNER JOIN [dbo].[PrecoTarifas] PT WITH(NOLOCK)
							ON PT.IdTarifa = T.Id
				WHERE T.Id = 6

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
			INSERT INTO [dbo].[Lancamentos]	(	Id_Cta,
												Id_Usuario,
												Id_TipoLancamento,
												Id_Tarifa,
												Tipo_Operacao,
												Vlr_Lanc,
												Nom_Historico,
												Dat_Lancamento,
												Estorno
											)
				SELECT	Id, 
						0,
						6,
						6,
						'D',
						@Valor_TMC,
						@Nome_Tarifa,
						@Data_Atual,
						0
					FROM [dbo].[Contas] WITH (NOLOCK)
					WHERE DAY(Dat_Abertura) = @Data_Cobranca
		END
GO