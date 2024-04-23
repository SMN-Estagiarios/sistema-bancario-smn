USE SistemaBancario
GO

CREATE OR ALTER TRIGGER [dbo].[TRG_AplicarTaxaAberturaConta]
ON [dbo].[Contas]
FOR INSERT
	AS
	/*
		DOCUMENTACAO
		Arquivo Fonte........:	TRG_AplicarTaxaAberturaConta.sql
		Objetivo.............:	Insere lancamento referente a taxa de abertura de conta.
								Id_Usuario = 0 Usuário do sistema
								Id_Tarifa = 5 que se refere a taxa de abertura de conta
								Tipo_Operacao = 'D', pois será um débito na conta 
								Estorno = 0, pois não será um estorno.
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
											(Vlr_SldInicial, Vlr_Credito, Vlr_Debito, Dat_Saldo, Dat_Abertura ,Ativo, Lim_ChequeEspecial)
										VALUES
											(0, 0, 0, GETDATE(), GETDATE(), 1, 0)

									SELECT DATEDIFF(MILLISECOND, @Dat_init, GETDATE()) AS TempoExecucao

									SELECT * FROM Contas ORDER BY Id DESC
									SELECT * FROM Lancamentos ORDER BY Id DESC

								ROLLBACK TRAN
	*/
	BEGIN
		-- Declaro as variaveis que preciso
		DECLARE @Id_Conta INT,
				@Vlr_Tarifa DECIMAL(15,2),
				@Data_Lancamento DATETIME = GETDATE()
				
		-- Atribuir valores as variaveis
		SELECT @Vlr_Tarifa = VT.Valor
			FROM [dbo].[FNC_ListarValorAtualTarifa](5) VT
				
		SELECT	@Id_Conta = Id
			FROM INSERTED

		-- Gero um novo lancamento com o valor da taxa
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
								VALUES	(	@Id_Conta,
											0,
											6,
											5,
											'D',
											@Vlr_Tarifa,
											'Taxa de abertura de conta',
											@Data_Lancamento,
											0
										)
		-- Checagem de erro
		DECLARE @MSG VARCHAR(100),
				@ERRO INT
			SET @ERRO = @@ERROR
			
				IF @@ERROR <> 0 OR @@ROWCOUNT <> 1
					BEGIN
						SET @MSG = 'ERRO' + CAST(@ERRO AS VARCHAR(3)) + ', na aplicacao de Taxa de Abertura de Conta'
							RAISERROR(@MSG, 16, 1)
					END
	END
GO