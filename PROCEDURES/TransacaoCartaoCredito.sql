USE SistemaBancario
GO

CREATE OR ALTER PROCEDURE [dbo].[SP_GerarTransacaoCartaoCredito]
			@Id_CartaoCredito INT,			
			@Id_ValorTaxaCartao INT,
			@Id_TipoTransacao INT,
			@Nom_Historico VARCHAR(500),			
			@Valor_Trans DECIMAL(15,2),
			@Estorno BIT
	AS
		/*
			Documentação
			Arquivo Fonte....: TransacaoCartaoCredito.sql
			Objetivo............: Fazer lançamento na entidade [dbo].[TransacaoCartaoCredito]
			Autor.................: Isabella Siqueira, Olivio Freitas, Orcino Neto
			Data.................: 25/04/2024
			EX....................:
									BEGIN TRAN
										DBCC DROPCLEANBUFFERS; 
										DBCC FREEPROCCACHE;
	
										DECLARE @Dat_init DATETIME = GETDATE(),
												@RET INT
										SELECT * FROM TransacaoCartaoCredito
	
										EXEC @RET = [dbo].[SP_GerarTransacaoCartaoCredito] 1,1,1,'Compra Realizada na Miranda', 100,0
										SELECT * FROM TransacaoCartaoCredito
	
										SELECT @RET AS RETORNO
	
										SELECT DATEDIFF(MILLISECOND, @Dat_init, GETDATE()) AS TempoExecucao
									ROLLBACK TRAN	
			Lista de Retornos:
			0: Sucesso
			1: Erro
		*/
		
	BEGIN
		--Setando @Id_Fatura para receber o id da fatura da conta especifica onde a fatura esteja aberta.
		DECLARE @Id_Fatura INT =  (SELECT f.Id 
										FROM [dbo].[Fatura] f WITH(NOLOCK)
											INNER JOIN [dbo].[Contas] ct WITH(NOLOCK)
												ON f.Id_Conta = ct.Id
											INNER JOIN [dbo].[CartaoCredito] cc WITH(NOLOCK)
												ON cc.Id_Conta = ct.Id
										WHERE cc.Id_Conta = f.Id_Conta AND f.Id_StatusFatura=1)
		DECLARE @Dat_Trans DATETIME = GETDATE()
		INSERT INTO [dbo].[TransacaoCartaoCredito] (Id_CartaoCredito,Id_Fatura,Id_ValorTaxaCartao,Id_TipoTransacao,Nom_Historico,Dat_Trans,Valor_Trans,Estorno)  VALUES
													(@Id_CartaoCredito,@Id_Fatura,@Id_ValorTaxaCartao,@Id_TipoTransacao,@Nom_Historico,@Dat_Trans,@Valor_Trans,@Estorno)
																			
		IF @@ROWCOUNT = 1
			RETURN 0
		ELSE
			RETURN 1
	END
GO