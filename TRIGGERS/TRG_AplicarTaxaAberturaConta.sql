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
							Id_Usuario = 0 Usu�rio do sistema
							Id_Tarifa = 5 que se refere a taxa de abertura de conta
							Tipo_Operacao = 'D', pois ser� um d�bito na conta 
							Estorno = 0, pois n�o ser� um estorno.
							Id_TipoLancamento = 6, referente a um Tarifa
	Autor................:	Olivio Freitas, Danyel Targino e Rafael Mauricio
	Data.................:	10/04/2024
	ObjetivoAlt..........:	A tabela de tarifas sofreu uma alteracao e os valores agora estao localizados na tabela PrecoTarifas,
							portanto preciso alterar para a nova estrutura do banco de dados
	AutorAlt.............:	Danyel Targino 
	DataAlt..............:	23/04/2024
	Ex...................:	BEGIN TRAN
								DBCC DROPCLEANBUFFERS;
								DBCC FREEPROCCACHE;

									DECLARE @Dat_init DATETIME = GETDATE()

									SELECT * FROM Contas ORDER BY Id DESC
									SELECT * FROM Lancamentos ORDER BY Id DESC

									INSERT INTO Contas
											(Id_CreditScore, Id_Correntista, Id_Usuario, Vlr_SldInicial, Vlr_Credito, Vlr_Debito, Dat_Saldo, Dat_Abertura, Ativo, Lim_ChequeEspecial)
										VALUES
											(1, 2, 0, 0, 0, 0, GETDATE(), GETDATE(), 1, 0)

									SELECT DATEDIFF(MILLISECOND, @Dat_init, GETDATE()) AS TempoExecucao

									SELECT * FROM Contas ORDER BY Id DESC
									SELECT * FROM Lancamentos ORDER BY Id DESC

								ROLLBACK TRAN
	*/
	BEGIN
		-- Declaro as variaveis que preciso
		DECLARE @Id_Conta INT,
				@Vlr_Tarifa DECIMAL(15,2),
				@Data_Lancamento DATETIME = GETDATE(),
				@IdTarifa TINYINT = 5
				
		-- Atribuir valores as variaveis
		SELECT @Vlr_Tarifa = VT.Valor
			FROM [dbo].[FNC_ListarValorAtualTarifa](@IdTarifa) VT
				
		SELECT	@Id_Conta = Id
			FROM INSERTED

		-- Gero um novo lancamento com o valor da taxa
		INSERT INTO [dbo].[Lancamentos]	(	Id_Conta, 
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
											@IdTarifa,
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