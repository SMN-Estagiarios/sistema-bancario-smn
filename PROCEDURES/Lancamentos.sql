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
	
						EXEC @RET = [dbo].[SP_CriarLancamentos]	1, 0, 1, 'D', 100, 'Saque', null, 0
						SELECT TOP 10 * FROM Lancamentos
	
						SELECT @RET AS RETORNO
	
						SELECT DATEDIFF(MILLISECOND, @Dat_init, GETDATE()) AS TempoExecucao
					ROLLBACK TRAN	
                                    
		    Lista de retornos:
                    0: Sucesso ao inserir o lançamento.
                    1: Valor de Lançamento tem que ser maior que 0.
                    2: Não permitido lançamentos futuros.
                    3: Não permitido lançamentos de meses diferentes.
                    4: Erro ao inserir lançamento.
		    */

	BEGIN
		-- Caso Valor do Lançamento seja menor que 0:
		IF @Vlr_Lanc < 0
			BEGIN			
				 RETURN 1
			END
		-- Caso Data de Lançamento do Insert seja maior que a data atual:
		IF @Dat_Lancamento > DATEADD(MINUTE, DATEDIFF(MINUTE, @Dat_Lancamento, GETDATE()), @Dat_Lancamento)
			BEGIN			 
				 RETURN 2
			END
		-- Caso o lançamento seja de mes anterior:
		IF DATEDIFF(MONTH,@Dat_Lancamento,GETDATE()) <> 0
			BEGIN			 
				RETURN 3
			END
		-- Caso a checagem tiver correta:
		ELSE	
			--Verificação se a conta tem saldo
			IF @Vlr_Lanc <= (SELECT [dbo].[FNC_CalcularSaldoDisponivel](@Id_Cta, NULL, NULL, NULL, NULL))
				BEGIN
			-- Caso paramentro seja NULL sera atribuido a variavel @DataAtual para recerber GETDATE
					IF @Dat_Lancamento IS NULL
						BEGIN
							DECLARE @DataAtual DATETIME
							SET @DataAtual = GETDATE()
	
							INSERT INTO [dbo].[Lancamentos] (Id_Conta,Id_Usuario,Id_TipoLancamento,Tipo_Operacao,Vlr_Lanc,Nom_Historico,Dat_Lancamento,Estorno) VALUES 
											(@Id_Cta, @Id_Usuario,@Id_TipoLancamento,@Tipo_Operacao,@Vlr_Lanc,@Nom_Historico,@DataAtual, @Estorno)
						END
	
					ELSE				
							INSERT INTO [dbo].[Lancamentos]  (Id_Conta,Id_Usuario,Id_TipoLancamento,Tipo_Operacao,Vlr_Lanc,Nom_Historico,Dat_Lancamento,Estorno) VALUES 
											 (@Id_Cta, @Id_Usuario,@Id_TipoLancamento,@Tipo_Operacao,@Vlr_Lanc,	@Nom_Historico,@DataAtual, @Estorno)
				END
				IF @@ROWCOUNT <> 0
					RETURN 0 
				ELSE 
					RETURN 4
	END
GO