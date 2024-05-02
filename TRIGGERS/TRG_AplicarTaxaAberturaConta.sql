USE SistemaBancario
GO

CREATE OR ALTER TRIGGER [dbo].[TRG_AplicarTaxaAberturaConta]
	ON [dbo].[Contas]
	FOR INSERT
AS
	/*
		DOCUMENTACAO
		Arquivo Fonte........:	TRG_AplicarTaxaAberturaConta.sql
		Objetivo.............:	Insere lancamento referente a tarifa de abertura de conta ao inserir uma nova conta.
								Id_Usuario = 0, Usuario do sistema
								Id_Tarifa = 5, Taxa de abertura de conta
								Tipo_Operacao = 'D', Debito na conta
								Estorno = 0, pois nao sera um estorno.
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
		
		-- Variáveis
			DECLARE @Id_Conta INT,
					@Vlr_Tarifa DECIMAL(15,2),
					@Data_Lancamento DATETIME = GETDATE(),
					@IdTarifa TINYINT = 4, --Tarifa de abertura de conta
					@IdPrecoTarifas INT;
				
		-- Selecionando o valor vigente para a tarifa de abertura de conta e o Id do registro com esta informação
			SELECT @Vlr_Tarifa = VT.Valor,
				   @IdPrecoTarifas = VT.IdPrecoTarifas
				FROM [dbo].[FNC_ListarValorAtualTarifa](@IdTarifa) VT
				
		-- Selecionando o Id da conta inserida para aplicar corretamente a tarifa
			SELECT	@Id_Conta = Id
				FROM INSERTED

		-- Inserindo o lançamento de tarifa de abertura de conta para a conta criada
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
					@ERRO INT = @@ERROR
				
			-- Verificando se houve erro ao inserir o lançamento com a cobrança de tarifa de abertura de conta
			IF @@ERROR <> 0 OR @@ROWCOUNT <> 1
				BEGIN
					SET @MSG = 'ERRO' + CAST(@ERRO AS VARCHAR(3)) + ', na aplicacao de Tarifa de Abertura de Conta'
						RAISERROR(@MSG, 16, 1)
				END

			-- Selecionando Id do lançamento que foi inserido
			DECLARE @IdLancamentoInserido INT = SCOPE_IDENTITY();
	
			-- Populando tabela de histórico de lançamentos originados por uma tarifa com a tarifa de abertura de conta para a conta criada
			INSERT INTO [dbo].[LancamentosPrecoTarifas] (
															Id_Lancamentos,
															Id_PrecoTarifas
														)
												VALUES	(
															@IdLancamentoInserido,
															@IdPrecoTarifas
														)
			
			-- Verificando possível novo erro
			SET @ERRO = @@ERROR
			
			-- Verificando se houve erro ao inserir histórico
			IF @@ERROR <> 0 OR @@ROWCOUNT <> 1
				BEGIN
					SET @MSG = 'ERRO' + CAST(@ERRO AS VARCHAR(3)) + ', na aplicacao de Tarifa de Abertura de Conta'
						RAISERROR(@MSG, 16, 1)
				END

		END
GO
