USE SistemaBancario
GO

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
										Id_TipoLancamento,
										Id_Tarifa,
										Tipo_Operacao,
										Vlr_Lanc,
										Nom_Historico,
										Dat_Lancamento,
										Estorno
									FROM [dbo].[Lancamentos] WITH(NOLOCK)
			
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
									FROM [dbo].[Contas]  WITH(NOLOCK)
                                
                                DBCC DROPCLEANBUFFERS
								DBCC FREEPROCCACHE
								DBCC FREESYSTEMCACHE ('ALL')

                                DECLARE @Data_ini DATETIME = GETDATE(),
                                        @RET INT;

								EXEC @RET = [dbo].[SPJOB_LancarTaxaSaldoNegativo]

								SELECT	Id,
										Vlr_SldInicial,
										Vlr_Credito,
										Vlr_Debito,
										Dat_Saldo,
										Dat_Abertura,
										Dat_Encerramento,
										Ativo 
									FROM [dbo].[Contas]  WITH(NOLOCK)

								SELECT DATEDIFF(MILLISECOND, @Data_ini, GETDATE()) AS TempoExecucao

                                SELECT @RET Retorno

								SELECT	Id_Cta,
										Id_Usuario,
										Id_TipoLancamento,
										Id_Tarifa,
										Tipo_Operacao,
										Vlr_Lanc,
										Nom_Historico,
										Dat_Lancamento,
										Estorno
									FROM [dbo].[Lancamentos] WITH(NOLOCK)

								TRUNCATE TABLE [dbo].[Lancamentos]
							ROLLBACK TRAN


            Lista de retornos:
            0: Sucesso ao lançar taxa.
            1: Não há contas com saldo negativo.
	*/

	BEGIN
		-- Aplicar a taxa de saldo negativo para as mesmas
		INSERT INTO [dbo].[Lancamentos]	(Id_Cta, Id_Usuario, Id_TipoLancamento, Id_Tarifa, Tipo_Operacao, Vlr_Lanc, Nom_Historico, Dat_Lancamento, Estorno)
			SELECT	s.Id,
					1,
					10,
					7,
					'D',
					(t.Taxa * ABS(s.Saldo)),
					'Valor REF sobre cobranças de limite cheque especial',
					GETDATE(),
					0
				FROM [dbo].FNC_ListarSaldoNegativo() s
					INNER JOIN [dbo].[Tarifas] t WITH(NOLOCK)
						ON t.Id = 7

				--IF @@ERROR <> 0 OR @@ROWCOUNT <> 1
		RETURN 0
	END

		