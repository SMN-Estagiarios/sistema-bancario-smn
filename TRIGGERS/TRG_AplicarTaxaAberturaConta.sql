USE SistemaBancario
GO

CREATE OR ALTER TRIGGER [dbo].[TRG_AplicarTaxaAberturaConta]
ON [dbo].[Contas]
FOR INSERT
	AS
		/*
			DOCUMENTACAO
			Arquivo Fonte........:	TRG_AplicarTaxaAberturaConta.sql
			Objetivo.............:	Insere lancamento referente a tarifa de abertura de conta.
									Id_Usuario = 0 Usu�rio do sistema
									Id_Tarifa = 5 que se refere a taxa de abertura de conta
									Tipo_Operacao = 'D', pois ser� um d�bito na conta 
									Estorno = 0, pois n�o ser� um estorno.
									Id_TipoLancamento = 6, referente a um Tarifa
			Autor................:	Danyel Targino
			Data.................:	23/04/2024
			Ex...................:	BEGIN TRAN
										DBCC DROPCLEANBUFFERS;
										DBCC FREEPROCCACHE;

											DECLARE @Dat_init DATETIME = GETDATE()

										SELECT * FROM Contas ORDER BY Id DESC
										SELECT * FROM Lancamentos ORDER BY Id DESC
									
										INSERT INTO Contas
												(Id_Correntista, Vlr_SldInicial, Vlr_Credito, Vlr_Debito, Dat_Saldo, Dat_Abertura , Ativo,Lim_ChequeEspecial)
											VALUES
												(1, 0, 0, 0, GETDATE(), GETDATE(), 1, 0)

											SELECT DATEDIFF(MILLISECOND, @Dat_init, GETDATE()) AS TempoExecucao

										SELECT * FROM Contas ORDER BY Id DESC
										SELECT * FROM Lancamentos ORDER BY Id DESC
									
										SELECT * FROM PrecoTarifas
										SELECT * FROM LancamentosPrecoTarifas

										ROLLBACK TRAN
		*/
	BEGIN
		
		DECLARE @Id_Conta INT,
				@Vlr_Tarifa DECIMAL(15,2),
				@Data_Lancamento DATETIME = GETDATE(),
				@IdTarifa TINYINT = 4, --Tarifa de abertura de conta
				@IdPrecoTarifas INT;
				
		SELECT @Vlr_Tarifa = VT.Valor,
			   @IdPrecoTarifas = VT.IdPrecoTarifas
			FROM [dbo].[FNC_ListarValorAtualTarifa](@IdTarifa) VT
				
		SELECT	@Id_Conta = Id
			FROM INSERTED

		INSERT INTO [dbo].[Lancamentos]	(	Id_Conta, 
											Id_Usuario, 
											Id_TipoLancamento, 
											Tipo_Operacao, 
											Vlr_Lanc, 
											Nom_Historico, 
											Dat_Lancamento, 
											Estorno
										)
								VALUES	(	@Id_Conta,
											0,
											6,
											'D',
											@Vlr_Tarifa,
											'Tarifa de abertura de conta',
											@Data_Lancamento,
											0
										)

		-- Checagem de erro
		DECLARE @MSG VARCHAR(100),
				@ERRO INT
			SET @ERRO = @@ERROR
			
				IF @@ERROR <> 0 OR @@ROWCOUNT <> 1
					BEGIN
						SET @MSG = 'ERRO' + CAST(@ERRO AS VARCHAR(3)) + ', na aplicacao de Tarifa de Abertura de Conta'
							RAISERROR(@MSG, 16, 1)
					END

		DECLARE @IdLancamentoInserido INT = SCOPE_IDENTITY();
	
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
					SET @MSG = 'ERRO' + CAST(@ERRO AS VARCHAR(3)) + ', na aplicacao de Tarifa de Abertura de Conta'
						RAISERROR(@MSG, 16, 1)
				END

	END
GO


