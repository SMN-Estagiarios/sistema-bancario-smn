USE SistemaBancario
GO

CREATE OR ALTER TRIGGER [dbo].[TRG_AtualizarCreditoComprometido]
	ON [dbo].[TransacaoCartaoCredito]
	AFTER INSERT
AS
	/*
		DOCUMENTAÇÃO
		Arquivo Fonte........:	TRG_AtualizarCreditoComprometido.sql
		Objetivo.............:	Atualizar limite comprometido da tabela [dbo].[CartaoCredito]
		Autor................:	Gabriel Damiani
		Data.................:	29/04/2024
		Ex...................: BEGIN TRAN
									DBCC DROPCLEANBUFFERS;
									DBCC FREEPROCCACHE;

									DECLARE @DATA_INI DATETIME = GETDATE();

									SELECT	Id_TipoTransacao,
											Valor_Trans,
											Estorno,
											Id_CartaoCredito
										FROM [dbo].[TransacaoCartaoCredito]
										WHERE Id = 1

										SELECT * FROM [dbo].[TransacaoCartaoCredito]
										SELECT * FROM [dbo].[CartaoCredito]

									INSERT INTO [dbo].[TransacaoCartaoCredito](	Id_CartaoCredito, 
																				Id_Fatura,
																				Id_ValorTaxaCartao,
																				Id_TipoTransacao,
																				Dat_Trans,
																				Nom_Historico,
																				Valor_Trans,
																				Estorno
																			)
										VALUES (1, 1, 3, 3, GETDATE(), 'TESTE TRIGGER', 500.50, 0)

									SELECT DATEDIFF(MILLISECOND, @DATA_INI,GETDATE()) AS TempoExecução

									SELECT	Id_TipoTransacao,
											Valor_Trans,
											Estorno,
											Id_CartaoCredito
										FROM [DBO].[TransacaoCartaoCredito]
										WHERE Id = 1

										SELECT * FROM [dbo].[TransacaoCartaoCredito]
										SELECT * FROM [dbo].[CartaoCredito]
								ROLLBACK TRAN
	*/
	BEGIN
		DECLARE @Tipo_Transacao CHAR(1),
				@Vlr_Trans DECIMAL(15,2),
				@Estorno BIT,
				@Id_CartaoCredito INT;
			 
		--ATRIBUINDO VALORES AS VARIÁVEIS 
		SELECT	@Tipo_Transacao = Id_TipoTransacao,
				@Vlr_Trans = Valor_Trans,
				@Estorno = Estorno,
				@Id_CartaoCredito = Id_CartaoCredito
			FROM INSERTED

		--SETANDO O VALOR DE CREDITO COMPROMETIDO COM BASE NA TRANSACAO
		UPDATE [dbo].[CartaoCredito] 
			SET LimiteComprometido =	CASE	WHEN @Estorno = 0
													THEN LimiteComprometido + @Vlr_Trans
												ELSE LimiteComprometido - @Vlr_Trans
										END
			WHERE Id = @Id_CartaoCredito
	END
