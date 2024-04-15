CREATE OR ALTER TRIGGER [DBO].[TRG_InserirTaxaSalgoNegativo]
	ON [DBO].[Contas]
	AFTER UPDATE
	AS
	 /*
		Documentação
		Arquivo Fonte.....:  TRG_InserirTaxaSalgoNegativo.sql
		Objetivo.............: Verificar diariamente quais contas estão negativas e aplicar a taxa de saldo negativo para a conta que estiver
		Autor.................: Orcino Neto, Odlavir Florentino e Pedro Avelino
		Data..................: 12/04/2024
		Ex.....................:		 BEGIN TRAN
											DBCC DROPCLEANBUFFERS
											DBCC FREEPROCCACHE
											DBCC FREESYSTEMCACHE ('ALL')

											DECLARE @DATA_INI DATETIME = GETDATE();

											UPDATE [DBO].[Contas]
												SET Vlr_SldInicial = '-10000'
												WHERE Id = 1

											SELECT * FROM [DBO].[Contas]
												WHERE Id = 1

											SELECT * FROM Lancamentos

											SELECT DATEDIFF(DAY, @DATA_INI, GETDATE())
										ROLLBACK TRAN
	 */

	 BEGIN
		DECLARE	@Id_CtaIN INT,
				@ValorSaldoInicialIN DECIMAL(15,2),
				@ValorSaldoInicialDE DECIMAL(15,2),
				@Id_CtaDE INT,
				@Taxa DECIMAL(15,4)

		SELECT @Id_CtaIN = Id, @ValorSaldoInicialIN = Vlr_SldInicial FROM inserted;
			SELECT @Id_CtaDE = Id, @ValorSaldoInicialDE = Vlr_SldInicial FROM deleted;

		IF @ValorSaldoInicialIN <> @ValorSaldoInicialDE
			BEGIN
				SET @Taxa = (SELECT Taxa FROM [DBO].Tarifas WITH(NOLOCK) WHERE Id = 7);			
					-- Verificando se o que está acontecendo é um update
					IF @Id_CtaDE IS NOT NULL AND @Id_CtaIN IS NOT NULL
						BEGIN
							-- Caso o Saldo inicial daquele registro que está sendo atualizado seja < 0, deverá ser lançado uma taxa de juros por dia naquele registro
							IF @ValorSaldoInicialIN < 0
								BEGIN									
									-- Inserir um lançamento para todas as contas com saldo inicial negativo
									INSERT Lancamentos (Id_Cta, Id_Usuario, Id_Tarifa, Tipo_Lanc, Vlr_Lanc, Nom_Historico, Dat_Lancamento) VALUES
									(@Id_CtaIN, 1, 7, 'D', (@Taxa * @ValorSaldoInicialIN * (-1)), 'Taxa de saldo negativo', GETDATE())
								END
						END
				END
		END
