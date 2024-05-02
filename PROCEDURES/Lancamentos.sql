USE SistemaBancario
GO

CREATE OR ALTER PROCEDURE [dbo].[SP_CriarLancamentos]
		@Id_Cta INT,
		@Id_Usuario INT,
		@Id_TipoLancamento INT,		
		@Tipo_Operacao CHAR(1),
		@Vlr_Lanc DECIMAL(15,2),
		@Nom_Historico VARCHAR(500),
		@Dat_Lancamento DATETIME,
		@Estorno BIT
	AS
		/*
		Documentação
		Arquivo Fonte..: Lancamentos.sql
		Objetivo..........:  Inserir Dados na Tabela Lançamentos, não permitir lançamentos futuros, nem retroativos de meses passados.
				    		 Digitar Null no paramentro @Dat_Lancamento ira receber GETDATE().
		Autor..............: Orcino Neto, Isabella Siqueira, Thays Carvalho
		Data...............: 18/04/2024
		Ex..................:	
					BEGIN TRAN
						DBCC DROPCLEANBUFFERS; 
						DBCC FREEPROCCACHE;
	
						DECLARE @Dat_init DATETIME = GETDATE(),
								@RET INT
						SELECT TOP 10 * FROM Lancamentos
	
						EXEC @RET = [dbo].[SP_CriarLancamentos]	1, 0, 1,1, 'C', 100, 'Deposito', null, 0
						SELECT TOP 10 * FROM Lancamentos
	
						SELECT @RET AS RETORNO
	
						SELECT DATEDIFF(MILLISECOND, @Dat_init, GETDATE()) AS TempoExecucao
					ROLLBACK TRAN	
                                    
		    Lista de retornos:
                     IdLancamento: Quando tiver sucesso ao inserir o lançamento.
                    -1: Valor de Lançamento tem que ser maior que 0.
                    -2: Não permitido lançamentos futuros.
                    -3: Não permitido lançamentos de meses diferentes.
                    -4: Erro ao inserir lançamento.
		    */

	BEGIN
		DECLARE @DataAtual DATETIME = GETDATE(),
				@ERRO INT,
				@Linha INT,
				@IdLancamento INT;

		-- Caso Valor do Lançamento seja menor que 0:
		IF @Vlr_Lanc < 0
			BEGIN			
				 RETURN -1
			END

		-- Caso Data de Lançamento do Insert seja maior que a data atual:
		IF @Dat_Lancamento > DATEADD(MINUTE, DATEDIFF(MINUTE, @Dat_Lancamento, @DataAtual), @Dat_Lancamento)
			BEGIN			 
				 RETURN -2
			END

		-- Caso o lançamento seja de mes anterior:
		IF DATEDIFF(MONTH,@Dat_Lancamento, @DataAtual) <> 0
			BEGIN			 
				RETURN -3
			END
			
		--Inserindo Lançamento				
		INSERT INTO [dbo].[Lancamentos] (Id_Conta,Id_Usuario,Id_TipoLancamento,Tipo_Operacao,
											Vlr_Lanc,Nom_Historico,Dat_Lancamento,Estorno) 
			VALUES (@Id_Cta, @Id_Usuario,@Id_TipoLancamento,@Tipo_Operacao,
						@Vlr_Lanc,@Nom_Historico,ISNULL(@Dat_Lancamento,@DataAtual), @Estorno)		
				
		SELECT  @ERRO = @@ERROR,
				@Linha = @@ROWCOUNT,
				@IdLancamento = SCOPE_IDENTITY()

		IF @ERRO <> 0 OR @Linha <> 1
			RETURN -4 
				
		RETURN @IdLancamento
	END
GO
