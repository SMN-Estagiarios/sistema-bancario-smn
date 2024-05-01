USE SistemaBancario
GO

CREATE OR ALTER TRIGGER [dbo].[TRG_GeraLancamentoSaque]
	ON [dbo].[TransacaoCartaoCredito]
	AFTER INSERT
	AS
		/*
		DOCUMENTAÇÃO
			Arquivo Fonte........: TRG_GeraLancamentoSaque.sql
			Objetivo.............:
			Autor................:
			Data.................:
			Ex...................: BEGIN TRANSACTION
											SELECT * from [dbo].[Lancamentos]
											
											SELECT * from [dbo].[Contas]

											SELECT * from [dbo].[TransacaoCartaoCredito]
										INSERT INTO [dbo].[TransacaoCartaoCredito] (
																					Id_CartaoCredito,
																					Id_Fatura,
																					Id_ValorTaxaCartao,
																					Id_TipoTransacao,
																					Nom_Historico,
																					Dat_Trans,
																					Valor_Trans, 
																					Estorno
																					)
																			VALUES
																					(
																					 4,
																					 1,
																					 1,
																					 2,
																					 'TESTE DO XABLAS',
																					 GETDATE(),
																					 500,
																					 0
																					)
											SELECT * from [dbo].[Lancamentos]
											
											SELECT * from [dbo].[Contas]

											SELECT * from [dbo].[TransacaoCartaoCredito]
								   
								   ROLLBACK TRANSACTION
								   
		*/
	BEGIN

			DECLARE @IdTransacao INT,
					@IdCartaoCredito INT,
					@IdFatura INT,
					@IdTipoTransacao INT,
					@NomHistorico VARCHAR(500),
					@DataTransferencia DATETIME,
					@Valor_Trans DECIMAL(15,2),
					@Estorno BIT,
					@IdConta INT,
					@IdValorTaxaCartao INT,
					@Taxa DECIMAL(6,5)

			SELECT  @IdTransacao = i.Id,
					@IdCartaoCredito = i.Id_CartaoCredito,
					@IdFatura = i.Id_Fatura,
					@IdTipoTransacao = i.Id_TipoTransacao,
					@IdValorTaxaCartao = Id_ValorTaxaCartao,
					@NomHistorico = i.Nom_Historico,
					@DataTransferencia = i.Dat_Trans,
					@Valor_Trans = i.Valor_Trans,
					@Estorno = i.Estorno,
					@IdConta = CC.Id_Conta
				FROM inserted i WITH (NOLOCK)
							INNER JOIN [dbo].[CartaoCredito] CC WITH (NOLOCK)
								ON i.Id_CartaoCredito = CC.Id
			 SELECT  @Taxa = X.Aliquota
					FROM (SELECT TOP 1 TX.Aliquota
									FROM ValorTaxaCartao TX
									WHERE DataInicial <= GETDATE()
									ORDER BY DataInicial DESC
									)X
					
				IF @IdTipoTransacao = 2
					BEGIN
					INSERT INTO [dbo].[Lancamentos]( Id_Conta,
													Id_Usuario,
													Id_TipoLancamento,
													Tipo_Operacao,
													Vlr_Lanc,
													Nom_Historico,
													Dat_Lancamento,
													Estorno
													)
											VALUES (@IdConta, 
													0,
													11,
													'C',
													@Valor_Trans,
													'Saque Cartao Credito',
													@DataTransferencia,
													0
													)
						
				

					INSERT INTO [dbo].[TransacaoCartaoCredito] (
																 Id_CartaoCredito,
																 Id_Fatura,
																 Id_ValorTaxaCartao,
																 Id_TipoTransacao,
																 Nom_Historico,
																 Dat_Trans,
																 Valor_Trans,
																 Estorno
															    )
														VALUES 
																(
																@IdCartaoCredito,
																@IdFatura,
																@IdValorTaxaCartao,
																@IdTipoTransacao,
																CONCAT('TAXA JUROS SOBRE TRANSACAO: ', @IdTransacao),
																@DataTransferencia,
																@Valor_Trans * @Taxa,
																@Estorno
																)
					END
	END
GO

