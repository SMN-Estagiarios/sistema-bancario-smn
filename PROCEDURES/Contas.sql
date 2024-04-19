USE SistemaBancario
GO

CREATE OR ALTER PROCEDURE [dbo].[SP_ListarSaldoAtual]
		@Id_Conta INT = NULL
		AS 
			/*
			Documentacao
			Arquivo Fonte.....: Contas.sql
			Objetivo..........: Listar o saldo atual de todas as contas ou uma conta espec�fica
			Autor.............: Adriel Alexsander, Isabela Tragante, Thays Carvalho 
 			Data..............: 02/04/2024
			Ex................:  DECLARE @RET INT, 
						         @Dat_init DATETIME = GETDATE()

								 EXEC @RET = [dbo].[SP_ListarSaldoAtual]
								 
								 SELECT @RET AS RETORNO,
										DATEDIFF(millisecond, @Dat_init, GETDATE()) AS TempoExecucao
			*/
	
		BEGIN
				SELECT  Id AS IdConta,
						[dbo].[FNC_CalcularSaldoAtual](@Id_Conta, Vlr_SldInicial, Vlr_Credito,Vlr_Debito)
				FROM [dbo].[Contas]
				WHERE Id = ISNULL(@Id_Conta, Id)
		END

GO 

CREATE OR ALTER PROCEDURE [dbo].[SP_ExcluirConta]
		@Id_Conta INT = NULL
		AS
        /*
		Documentacao
		Arquivo Fonte.....: Contas.sql
		Objetivo..........: Exclui uma conta existente com base no seu Id
		Autor.............: Adriel Alexsander, Isabela Tragante, Thays Carvalho
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
							01.................: Conta nao existe
							02.................: Conta possui Lancamentos         
	   */
		BEGIN
		--Checar se o Id da conta existe dentro do Banco
			IF NOT EXISTS( SELECT TOP 1 1
								FROM [dbo].[Contas] C WITH(NOLOCK)
								WHERE C.Id = @Id_Conta)
				BEGIN 
					RETURN 1
				END
		--Se existe Lancamentos para essa Conta
		    IF EXISTS (SELECT TOP 1 1
								FROM [dbo].[Lancamentos] L WITH(NOLOCK)
								WHERE L.Id_Cta = @Id_Conta)
				BEGIN
					RETURN 2
				END
			ELSE
				BEGIN
				--Excluir do registro de conta passado por paramentro
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
			Documentacao
			Arquivo Fonte.....: Contas.sql
			Objetivo..........: Atualiza Campos Especificos de uma conta com base no seu Id 
			Autor.............: Adriel Alexsander, Isabela Tragante, Thays Carvalho
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

									EXEC @RET = [dbo].[SP_AtualizarConta] 1, Credito , 200

									SELECT @RET AS RETORNO,
										   DATEDIFF(millisecond, @Dat_init, GETDATE()) AS TempoExecucao

									SELECT  Id,
											Vlr_SldInicial,
											Vlr_Credito,
											Vlr_Debito,
											Dat_Saldo 
										FROM [dbo].[Contas]

								ROLLBACK TRAN

									--	RETORNO --
									00.................: Sucesso
									01.................: Conta n�o existe
									02.................: Valores nulo nos parametros passados  
									03.................: Valor do parametro @Campo Invalido
									04.................: Valor do parametro @Vlr_Atualizacao Invalido
		*/
		BEGIN
			--Verificar se a conta existe
			IF NOT EXISTS( SELECT TOP 1 1
									FROM [dbo].[Contas] C WITH(NOLOCK)
									WHERE C.Id = @Id_Conta)
					BEGIN 
						RETURN 1
					END	
			--Verificar se as variaveis passadas nao sao nulas
			IF(	@Id_Conta IS NULL OR 
				@Campo IS NULL OR 
				@Vlr_Atualizacao IS NULL)
				
				BEGIN
					RETURN 2
				END
			IF(	@Campo NOT LIKE 'Cr[e,é]dito' AND 
				@Campo NOT LIKE 'D[e,é]bito')
				BEGIN
					RETURN 3
				END
					
			IF (@Vlr_Atualizacao IS NULL OR 
				@Vlr_Atualizacao < 0)
				BEGIN 
					RETURN 4
				END 
			ELSE
				BEGIN		
					-- Atualiza a conta com base no Id
					UPDATE [dbo].[Contas] 
						SET  Vlr_Credito = CASE WHEN @Campo LIKE 'Cr[e,é]dito' 
												THEN  @Vlr_Atualizacao 
												ELSE Vlr_Credito 
											END,
							Vlr_Debito =   CASE	WHEN @Campo LIKE 'D[e,é]bito' 
												THEN  @Vlr_Atualizacao
												ELSE Vlr_Debito 
											END
						WHERE Id = @Id_Conta
						RETURN 0
				END
		END
GO

CREATE OR ALTER PROCEDURE [dbo].[SP_InserirNovaConta] 
		AS 
			/*
				Documentacao
				Arquivo Fonte.....: Contas.sql
				Objetivo..........: Cria uma conta na tabela [dbo].[Contas]
				Autor.............: Adriel Alexsander, Isabela Tragante, Thays Carvalho
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

										EXEC @RET = [dbo].[SP_InserirNovaConta]

											SELECT @RET AS RETORNO,
												DATEDIFF(millisecond, @Dat_init, GETDATE()) AS TempoExecucao
													SELECT	Id,
															Vlr_SldInicial,
															Vlr_Credito,
															Vlr_Debito,
															Dat_Saldo 
														FROM [dbo].[Contas]
								ROLLBACK TRAN

				--	RETORNO   --
				00.................: Erro ao criar conta
				01.................: Sucesso
																
			*/
		BEGIN
			
				
			INSERT INTO Contas(Vlr_SldInicial, Vlr_Credito, Vlr_Debito, Dat_Saldo, Dat_Abertura, Ativo, Lim_ChequeEspecial) 
			VALUES
				(0, 0, 0, GETDATE(), GETDATE(), 1, 0);

			IF @@ROWCOUNT <> 0
				RETURN 1
			ELSE
				RETURN 0
				
		END
GO
