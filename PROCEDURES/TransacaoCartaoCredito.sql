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
											SELECT * FROM CartaoCredito
											EXEC @RET = [dbo].[SP_GerarTransacaoCartaoCredito] 1,1,1,'Compra Realizada na Miranda', 985,0											
											SELECT * FROM TransacaoCartaoCredito
											SELECT * FROM CartaoCredito
											SELECT @RET AS RETORNO
	
											SELECT DATEDIFF(MILLISECOND, @Dat_init, GETDATE()) AS TempoExecucao
										ROLLBACK TRAN
			Lista de Retornos:
			0: Sucesso
			1: Erro
		*/		
	BEGIN
		--Setando Variavel para receber o Limite comprometido daquele cartao de credito.
		DECLARE @LimiteComprometido DECIMAL(15,2) = (SELECT cc.LimiteComprometido
																						FROM [dbo].[CartaoCredito] cc WITH(NOLOCK)																							
																						WHERE cc.Id = @Id_CartaoCredito)
		--Setando Variavel para receber o Limite daquele cartao de credito.
		DECLARE @Limite DECIMAL(15,2) = (SELECT Limite 
																	FROM [dbo].[CartaoCredito]cc WITH(NOLOCK)
																		WHERE cc.Id= @Id_CartaoCredito)
		--Setando a diferença do Limte com Limete Comprometido
		DECLARE @Diff DECIMAL(15,2) = @Limite - @LimiteComprometido
		--Verificando se o valor da transação do cartao de credito seja igual ou inferior ao limite disponivel.
		IF @Valor_Trans <= @Diff
			BEGIN
					DECLARE @Dat_Trans DATETIME = GETDATE()
					INSERT INTO [dbo].[TransacaoCartaoCredito] (Id_CartaoCredito,Id_ValorTaxaCartao,Id_TipoTransacao,Nom_Historico,Dat_Trans,Valor_Trans,Estorno)  VALUES
																					  (@Id_CartaoCredito,@Id_ValorTaxaCartao,@Id_TipoTransacao,@Nom_Historico,@Dat_Trans,@Valor_Trans,@Estorno)
			END
		IF @@ROWCOUNT = 1
			RETURN 0
		ELSE
			RETURN 1
	END
GO