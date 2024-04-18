CREATE OR ALTER PROCEDURE [dbo].[SPJOB_LancarTaxaSaldoNegativo]
	AS
	/*
		DOCUMENTAÇÃO
		Arquivo fonte.....: SPJOB_LancarTaxaSaldoNegativo.sql
		Objetivo..........: Verificar diariamente quais as contas que estão negativas e lançar uma taxa de saldo nelas.
		Autor.............: Orcino Neto, Odlavir Florentino e Pedro Avelino
		Data..............: 18/04/2024
		Ex................: BEGIN TRAN
								
								SELECT	Id_Cta,
										Id_Usuario,
										Id_Tarifa,
										Tipo_Lanc,
										Vlr_Lanc,
										Nom_Historico,
										Dat_Lancamento,
										Estorno
									FROM [dbo].[Lancamentos]
			
								UPDATE Contas
									SET Vlr_SldInicial = -15000,
										Vlr_Credito = 15000,
										Vlr_Debito = 500
									--WHERE Id = 1

								SELECT	Id,
										Vlr_SldInicial,
										Vlr_Credito,
										Vlr_Debito,
										Dat_Saldo,
										Dat_Abertura,
										Dat_Encerramento,
										Ativo 
									FROM Contas
                                
                                DBCC DROPCLEANBUFFERS
								DBCC FREEPROCCACHE
								DBCC FREESYSTEMCACHE ('ALL')

                                DECLARE @Data_ini DATETIME = GETDATE(),
                                        @RET INT;

								EXEC @RET = [dbo].[SPJOB_LancarTaxaSaldoNegativo]

								SELECT DATEDIFF(MILLISECOND, @Data_ini, GETDATE()) AS TempoExecucao

                                SELECT @RET Retorno

								SELECT	Id_Cta,
										Id_Usuario,
										Id_Tarifa,
										Tipo_Lanc,
										Vlr_Lanc,
										Nom_Historico,
										Dat_Lancamento,
										Estorno
									FROM [dbo].[Lancamentos]

								TRUNCATE TABLE [dbo].[Lancamentos]
							ROLLBACK TRAN


            Lista de retornos:
            0: Sucesso ao lançar taxa.
            1: Não há contas com saldo negativo.
	*/

	BEGIN
		-- Conferir se existe conta(s) com saldo negativo no dia
		IF EXISTS (SELECT TOP 1 1
						FROM FNC_ListarSaldoNegativo())
			BEGIN
				-- Declarar variável da taxa e setar o seu valor
				DECLARE @Taxa DECIMAL(6,5)

				SET @Taxa = (SELECT Taxa FROM Tarifas WHERE Id = 7)

				-- Aplicar a taxa de saldo negativo para as mesmas
				INSERT INTO [dbo].[Lancamentos]	(Id_Cta, Id_Usuario, Id_Tarifa, Tipo_Lanc, Vlr_Lanc, Nom_Historico, Dat_Lancamento, Estorno)
					SELECT	Id ,
							1,
							7,
							'D',
							(@Taxa * ABS(Saldo)),
							'Valor REF sobre cobranças de limite cheque especial',
							GETDATE(),
							0
						FROM FNC_ListarSaldoNegativo()

				RETURN 0
			END

		ELSE
			BEGIN
				RETURN 1
			END
	END
		