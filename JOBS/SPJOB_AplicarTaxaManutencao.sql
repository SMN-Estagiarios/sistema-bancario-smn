USE SistemaBancario
GO

CREATE OR ALTER PROCEDURE [dbo].[SPJOB_AplicarTaxaManutencao]
	AS
		/*
			Documentacao
			Arquivo Fonte........:	SPJOB_AplicarTaxaManutencao.sql
			Objetivo.............:	Aplica a Tarifa de Manutencao de Conta a partir da data de abertura da conta nos meses subsequentes
									Id_Usuario o valor é 0, pois é usuario do sistema
									Id_TipoLancamento o valor é 6, pois refere-se a Tarifa
									Id_Tarifa o valor é 6, pois refere-se a Tarifa de Manutencao de Conta (TMC)
			Autor................:	Gustavo Targino, Danyel Targino e Thays Carvalho
			Data.................:	29/04/2024
			Ex...................:	BEGIN TRAN
										DBCC DROPCLEANBUFFERS;
										DBCC FREEPROCCACHE;

										DECLARE @RET INT, 
												@Dat_init DATETIME = GETDATE()

										SELECT * FROM Contas ORDER BY Dat_Abertura DESC
										SELECT * FROM Lancamentos ORDER BY Dat_Lancamento DESC

										INSERT INTO Contas
												(Id_Correntista, Vlr_SldInicial, Vlr_Credito, Vlr_Debito, Dat_Saldo, Dat_Abertura , Ativo, Lim_ChequeEspecial)
											VALUES
												(1, 0, 0, 0, GETDATE(), DATEFROMPARTS(YEAR(@Dat_init), MONTH(DATEADD(MONTH, -1, @Dat_init)), DAY(@Dat_init)), 1, 0)

										EXEC @RET = [dbo].[SPJOB_AplicarTaxaManutencao];

										SELECT	@RET AS RETORNO,
												DATEDIFF(MILLISECOND, @Dat_init, GETDATE()) AS TempoExecucao
										
										SELECT * FROM Lancamentos
										SELECT * FROM Contas
										SELECT * FROM Tarifas
										SELECT * FROM PrecoTarifas
										SELECT * FROM LancamentosPrecoTarifas

									ROLLBACK TRAN
		*/

			-- Declarando variaveis
			DECLARE @Data_Atual DATE = GETDATE(),
					@Data_Abertura DATE,
					@Data_Cobranca INT,
					@Valor_TMC DECIMAL(4,2),
					@Nome_Tarifa VARCHAR(50),
					@IdTarifa TINYINT = 5 -- Tarifa de manutenção de conta
					
			SELECT @Data_Abertura = Dat_Abertura
				FROM Contas
				WHERE DATEDIFF(MONTH, Dat_Abertura, @Data_Atual) > 0
				AND DAY(Dat_Abertura) = DAY(@Data_Atual)

			-- Capturar Id_Taxa e Valor da Taxa
			SELECT	@Valor_TMC = Valor,
					@Nome_Tarifa = Nome
				FROM [dbo].[FNC_ListarValorAtualTarifa](@IdTarifa)

			-- Comparar Mes/Ano Atual > DataAbertura Lancar @Data_Cobranca
			IF DAY(EOMONTH(@Data_Atual)) < DAY(@Data_Abertura)
				SET @Data_Cobranca = DAY(EOMONTH(@Data_Atual));
			ELSE
				SET @Data_Cobranca = DAY(@Data_Abertura); 
				
			-- Insert dos LANCAMENTOS
			INSERT INTO [dbo].[Lancamentos]	(	
								Id_Conta,
								Id_Usuario,
								Id_TipoLancamento,
								Tipo_Operacao,
								Vlr_Lanc,
								Nom_Historico,
								Dat_Lancamento,
								Estorno
							)
				SELECT	Id, 
						0,
						6, -- Tarifa
						'D',
						@Valor_TMC,
						@Nome_Tarifa,
						@Data_Atual,
						0
					FROM [dbo].[Contas] WITH (NOLOCK)
					WHERE DAY(Dat_Abertura) = @Data_Cobranca

			-- Checagem de erro
			DECLARE @MSG VARCHAR(100),
					@ERRO INT
				SET @ERRO = @@ERROR
			
					IF @@ERROR <> 0 OR @@ROWCOUNT <> 1
						BEGIN
							SET @MSG = 'ERRO' + CAST(@ERRO AS VARCHAR(3)) + ', na aplicacao de Tarifa de Manutenção de Conta'
								RAISERROR(@MSG, 16, 1)
						END

			DECLARE @IdLancamentoInserido INT = SCOPE_IDENTITY(),
					@IdPrecoTarifas INT;
	
			SELECT @IdPrecoTarifas = IdPrecoTarifas
				FROM [dbo].[FNC_ListarValorAtualTarifa](@IdTarifa);

			INSERT INTO [dbo].[LancamentosPrecoTarifas] (
															Id_Lancamentos,
															Id_PrecoTarifas
														)
												VALUES	(
															@IdLancamentoInserido,
															@IdPrecoTarifas
														)

			SET @ERRO = @@ERROR
			
				IF @@ERROR <> 0 OR @@ROWCOUNT <> 1
					BEGIN
						SET @MSG = 'ERRO' + CAST(@ERRO AS VARCHAR(3)) + ', na aplicacao de Tarifa de Manutenção de Conta'
							RAISERROR(@MSG, 16, 1)
					END
GO