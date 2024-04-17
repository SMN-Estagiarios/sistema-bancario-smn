USE SistemaBancario
GO

CREATE OR ALTER PROCEDURE [dbo].[SP_ListarSaldoAtual]
		@Id_Conta INT = NULL
		AS 
			/*
			Documentação
			Arquivo Fonte.....: Contas.sql
			Objetivo..........: Listar o saldo atual de todas as contas ou uma conta específica
			Autor.............: Adriel Alexsander 
 			Data..............: 02/04/2024
			Ex................:  DECLARE @RET INT, 
						         @Dat_init DATETIME = GETDATE()

								 EXEC @RET = [dbo].[SP_ListarSaldoAtual]
								 
								 SELECT @RET AS RETORNO,
										DATEDIFF(millisecond, @Dat_init, GETDATE()) AS EXECUÇÃO 	
			*/
	
		BEGIN
				SELECT  Id AS IdConta,
						[dbo].[Func_CalculaSaldoAtual](@Id_Conta, Vlr_SldInicial, Vlr_Credito,Vlr_Debito)
				FROM Contas
				WHERE Id = ISNULL(@Id_Conta, Id)
		END

GO 

CREATE OR ALTER PROCEDURE [dbo].[SP_ExcluirConta]
		@Id_Conta INT = NULL
		AS
        /*
		Documentação
		Arquivo Fonte.....: Contas.sql
		Objetivo..........: Exclui uma conta existente com base no seu Id
		Autor.............: Adriel Alexsander 
 		Data..............: 02/04/2024
		Ex................: BEGIN TRAN
								DBCC DROPCLEANBUFFERS;
								DBCC FREEPROCCACHE;

									DECLARE @RET INT, 
									@Dat_init DATETIME = GETDATE()
									SELECT  Id,
											Vlr_SldInicial,
											Vlr_Credito,
											Vlr_Debito,
											Dat_Saldo 
										FROM [dbo].[Contas]

									EXEC @RET = [SP_ExcluirConta] 1
									SELECT @RET AS RETORNO,
										   DATEDIFF(millisecond, @Dat_init, GETDATE()) AS EXECUCAO 	

									SELECT  Id,
											Vlr_SldInicial,
											Vlr_Credito,
											Vlr_Debito,
											Dat_Saldo 
										FROM [dbo].[Contas]
							ROLLBACK TRAN

						--	RETORNO  --
							00.................: Sucesso
							01.................: Conta não existe
							02.................: Conta possui Lançamentos         
	   */
		BEGIN
		--Checar se o Id da conta existe dentro do Banco
			IF NOT EXISTS( SELECT TOP 1 1
								FROM [dbo].[Contas] C WITH(NOLOCK)
								WHERE C.Id = @Id_Conta)
				BEGIN 
					RETURN 1
				END
		--Se existe Lançamentos para essa Conta
		    IF EXISTS (SELECT TOP 1 1
								FROM [dbo].[Lancamentos] L WITH(NOLOCK)
								WHERE L.Id_Cta = @Id_Conta)
				BEGIN
					RETURN 2
				END
			ELSE
				BEGIN
				--deleção do registro de conta passado por parâmentro
					DELETE FROM [dbo].[Contas] 
						   WHERE Id = @Id_Conta
						   RETURN 0
          		END   
		END
GO
	
CREATE OR ALTER PROCEDURE [dbo].[SP_AtualizarConta]
		@Id_Conta INT,
		@Campo VARCHAR(20),
		@Vlr_Atualizacao DECIMAL(15,2)
		AS
		/*
			Documentação
			Arquivo Fonte.....: Contas.sql
			Objetivo..........: Atualiza Campos Especificos de uma conta com base no seu Id 
			Autor.............: Adriel Alexsander 
 			Data..............: 02/04/2024
			Ex................: BEGIN TRAN
								DBCC DROPCLEANBUFFERS;
								DBCC FREEPROCCACHE;

									DECLARE @RET INT, 
									@Dat_init DATETIME = GETDATE()
									SELECT  Id,
											Id_Usuario,
											Vlr_SldInicial,
											Vlr_Credito,
											Vlr_Debito,
											Dat_Saldo 
										FROM [dbo].[Contas]

									EXEC @RET = [dbo].[SP_AtualizarConta] 1, Credito , 200

									SELECT @RET AS RETORNO,
										   DATEDIFF(millisecond, @Dat_init, GETDATE()) AS EXECUÇÃO 

									SELECT  Id,
											Id_Usuario,
											Vlr_SldInicial,
											Vlr_Credito,
											Vlr_Debito,
											Dat_Saldo 
										FROM [dbo].[Contas]

								ROLLBACK TRAN

								--	RETORNO --
									00.................: Sucesso
									01.................: Conta não existe
									02.................: Valores nulo nos parametros passados  
									03.................: Valor do parâmetro @Campo Invalido
									04.................: Valor do parâmetro @Vlr_Atualizacao Invalido
		*/
		BEGIN
			--Verificar se a conta existe
			IF NOT EXISTS( SELECT TOP 1 1
									FROM [dbo].[Contas] C WITH(NOLOCK)
									WHERE C.Id = @Id_Conta)
					BEGIN 
						RETURN 1
					END	
			--Verificar se as variáveis passadas não são nulas
			IF(	@Id_Conta IS NULL OR 
				@Campo IS NULL OR 
				@Vlr_Atualizacao IS NULL)
				
				BEGIN
					RETURN 2
				END
			IF(	@Campo NOT LIKE 'Cr[eé]dito' AND 
				@Campo NOT LIKE 'D[eé]bito')
				BEGIN
					RETURN 3
				END
					
			IF (@Vlr_Atualizacao IS NULL OR 
				@Vlr_Atualizacao < 0)
				BEGIN 
					RETURN 4
				END 
			ELSE
				BEGIN		-- Atualiza a conta com base no Id
					UPDATE [dbo].[Contas] 
						SET  Vlr_Credito = CASE WHEN @Campo LIKE 'Cr[ée]dito' 
												THEN  @Vlr_Atualizacao 
												ELSE Vlr_Credito 
											END,
							Vlr_Debito =   CASE	WHEN @Campo LIKE 'D[eé]bito' 
												THEN  @Vlr_Atualizacao
												ELSE Vlr_Debito 
											END
						WHERE Id = @Id_Conta
						RETURN 0
				END
		END
GO

CREATE OR ALTER PROCEDURE [dbo].[SP_InserirNovaConta] 
		@Vlr_SldInicial DECIMAL(15,2) = 0,
		@Vlr_Credito DECIMAl(15,2) = 0,
		@Vlr_Debito DECIMAL(15,2) = 0
		AS 
		/*
			Documentação
			Arquivo Fonte.....: Contas.sql
			Objetivo..........: Cria uma conta tendo como base um usuario existente 
			Autor.............: Adriel Alexsander 
 			Data..............: 02/04/2024
			Ex................: BEGIN TRAN
									DBCC DROPCLEANBUFFERS;
									DBCC FREEPROCCACHE;

									DECLARE @RET INT, 
									@Dat_init DATETIME = GETDATE()

										SELECT  Id,
											Vlr_SldInicial,
											Vlr_Credito,
											Vlr_Debito,
											Dat_Saldo 
										FROM [dbo].[Contas]

									EXEC @RET = [dbo].[SP_InserirNovaConta] 0, 200, 400 

										SELECT @RET AS RETORNO,
											   DATEDIFF(millisecond, @Dat_init, GETDATE()) AS EXECUÇÃO
												SELECT  Id,
												Vlr_SldInicial,
												Vlr_Credito,
												Vlr_Debito,
												Dat_Saldo 
											FROM [dbo].[Contas]
							   ROLLBACK TRAN

								--	RETORNO   --
										00.................: Sucesso
										01.................: Parametros com valores negativo						
		*/
		BEGIN
			IF(	@Vlr_Credito < 0 OR 
				@Vlr_Debito < 0 OR 
				@Vlr_SldInicial < 0 )
				BEGIN
					RETURN 1
				END
			ELSE
				BEGIN
					INSERT INTO Contas(Vlr_SldInicial, Vlr_Credito, Vlr_Debito, Dat_Saldo, Dat_Abertura, Ativo, Lim_ChequeEspecial) 
					values
						(@Vlr_SldInicial, @Vlr_Credito, @Vlr_Debito, GETDATE(), GETDATE(), 'S', 0);
					RETURN 0
				END
		END
GO
