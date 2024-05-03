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
	Arquivo Fonte.....: TransacaoCartaoCredito.sql
	Objetivo..........: Fazer lançamento na entidade [dbo].[TransacaoCartaoCredito]
	Autor.............: Isabella Siqueira, Olivio Freitas, Orcino Neto
	Data..............: 25/04/2024
	EX................:
						BEGIN TRAN
							DBCC DROPCLEANBUFFERS; 
							DBCC FREEPROCCACHE;
	
							DECLARE @Dat_init DATETIME = GETDATE(),
											@RET INT
							SELECT * FROM CartaoCredito
							SELECT * FROM TransacaoCartaoCredito
							EXEC @RET = [dbo].[SP_GerarTransacaoCartaoCredito] 4,1,1,'Compra Realizada na SMN', 5,0											
							SELECT * FROM TransacaoCartaoCredito
							SELECT * FROM CartaoCredito
							SELECT @RET AS RETORNO
	
							SELECT DATEDIFF(MILLISECOND, @Dat_init, GETDATE()) AS TempoExecucao
						ROLLBACK TRAN
	Lista de Retornos:
				0 - Sucesso.
				1 - Erro cartão não encontrado.
				2 - Erro ao inserir dados na transação.
				3 - Sem Limite para executar transação.
	*/		
	BEGIN	
		--Verificação se existe cartao de credito.
		IF NOT EXISTS (SELECT TOP 1 1
							FROM [dbo].[CartaoCredito] WITH(NOLOCK)
							WHERE Id = @Id_CartaoCredito)
			BEGIN
				RETURN 1
			END		

		--Verificando se o valor da transação do cartao de credito seja igual ou inferior ao limite disponivel.
		IF @Valor_Trans > (SELECT	cc.Limite - cc.LimiteComprometido									
								FROM [dbo].[CartaoCredito] cc WITH(NOLOCK)																							
								WHERE cc.Id = @Id_CartaoCredito)
			RETURN 3
		
		--Inserindo Transação
		INSERT INTO [dbo].[TransacaoCartaoCredito] (
														Id_CartaoCredito,
														Id_ValorTaxaCartao,
														Id_TipoTransacao,
														Nom_Historico,
														Dat_Trans,
														Valor_Trans,
														Estorno
													) 
											VALUES
													(
														@Id_CartaoCredito,
														@Id_ValorTaxaCartao,
														@Id_TipoTransacao,
														@Nom_Historico,
														GETDATE(),
														@Valor_Trans,
														@Estorno
													)
		IF @@ERROR <> 0 OR @@ROWCOUNT = 0
			RETURN 2
			
		RETURN 0
	END
GO