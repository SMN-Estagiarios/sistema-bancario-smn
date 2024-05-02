CREATE OR ALTER PROCEDURE [dbo].[SP_InserirNovoCorrentista] 
		@Nome VARCHAR(500),		
		@Cpf BIGINT,
		@DataN DATE,		
		@Contato BIGINT,
		@Email VARCHAR(500),
		@Lograouro VARCHAR(500),
		@Numero SMALLINT,
		@Ativo BIT
		
		AS 
			/*
				Documentacao
				Arquivo Fonte.....: Correntista.sql
				Objetivo..........: Cria uma conta na tabela [dbo].[Correntista]
				Autor.............: Orcino Neto, Olivio Freitas, Isabela Siqueira
				Data..............: 24/04/2024
				Ex................: BEGIN TRAN
										DBCC DROPCLEANBUFFERS;
										DBCC FREEPROCCACHE;

										DECLARE @RET INT, 
										@Dat_init DATETIME = GETDATE()

											SELECT  Id,
														 Nome,
														 Cpf,
														 DataNasc,
														 Contato,
														 Email,
														 Logradouro,
														 Numero,
														 Ativo
												FROM [dbo].[Correntista] 

										EXEC @RET = [dbo].[SP_InserirNovoCorrentista] 'Finado Betoneira',24242424242,'2000-02-24',24242424242,'betuoneira@gmail.com','Rua Tatu Molhado', null,1

											SELECT @RET AS RETORNO,
												DATEDIFF(millisecond, @Dat_init, GETDATE()) AS TempoExecucao
											SELECT Id,
														Nome,
														Cpf,
														DataNasc,
														Contato,
														Email,
														Logradouro,
														Numero,
														Ativo
												FROM [dbo].[Correntista]
								ROLLBACK TRAN

				--	RETORNO   --
				00.................: Erro ao criar conta
				01.................: Sucesso																
			*/
		BEGIN
				
			INSERT INTO [dbo].[Correntista] (Nome,Cpf,DataNasc,Contato,Email,Logradouro,Numero,Ativo) VALUES   				
															(@Nome, @Cpf,@DataN,@Contato,@Email,@Lograouro,@Numero,@Ativo);

			IF @@ROWCOUNT <> 0
				RETURN 0
			ELSE
				RETURN 1
				
		END
GO


CREATE OR ALTER PROCEDURE [dbo].[SP_ExcluirCorrentista]
		@Id_Correntista INT = NULL
		AS
        /*
		Documentacao
		Arquivo Fonte.....: Correntista.sql
		Objetivo..........: Mudar para desativo um correntista
		Autor.............: Orcino Neto, Olivio Freitas, Isabela Siqueira
		Data..............: 24/04/2024
		Ex................: BEGIN TRAN
								DBCC DROPCLEANBUFFERS;
								DBCC FREEPROCCACHE;

									DECLARE @RET INT, 
									@Dat_init DATETIME = GETDATE()
									SELECT  Id,
												Nome,
												Cpf,
												DataNasc,
												Contato,
												Email,
												Logradouro,
												Numero,
												Ativo
									FROM [dbo].[Correntista] 

									SELECT * FROM Contas

									EXEC @RET = [SP_ExcluirCorrentista] 8
									SELECT @RET AS RETORNO,
										   DATEDIFF(millisecond, @Dat_init, GETDATE()) AS EXECUCAO 	

										SELECT * FROM Contas

									SELECT  Id,
												Nome,
												Cpf,
												DataNasc,
												Contato,
												Email,
												Logradouro,
												Numero,
												Ativo
									FROM [dbo].[Correntista] 
							ROLLBACK TRAN

						--	RETORNO  --
							00.................: Sucesso.
							01.................:	Erro.
							02.................: Conta deve estar com saldo 0.         
	   */
		BEGIN
		--Checar se o Id existe conta vinculada aquele correntista ou se a conta vinculada esta inativa.
			IF  NOT EXISTS( SELECT TOP 1 1
										FROM [dbo].[Contas]  WITH(NOLOCK)
										WHERE Id_Correntista = @Id_Correntista OR Ativo = 0)
				BEGIN 
					UPDATE [dbo].Correntista  SET Ativo = 0				
						   WHERE Id = @Id_Correntista
						   RETURN 0					
				END
		--Checa se tem conta vinculada ao correntista ou se a conta esta ativa
		    IF EXISTS (SELECT TOP 1 1
								FROM [dbo].[Contas] WITH(NOLOCK)
								WHERE Id_Correntista = @Id_Correntista AND Ativo = 1)			
				BEGIN		
					--Declaração das variaveis 
					DECLARE @IdConta INT,
								  @RET INT
						--Setando variavel 
						SELECT @IdConta = Id
							FROM [dbo].[Contas] WITH(NOLOCK)
							WHERE Id_Correntista = @Id_Correntista
					
							EXEC @RET =   [dbo].[SP_ExcluirConta] @IdConta
							 IF @RET = 0
								BEGIN
									EXEC  [dbo].[SP_ExcluirConta] @IdConta
									UPDATE [dbo].[Correntista]  SET Ativo = 0				
										   WHERE Id = @Id_Correntista
										   RETURN 0									
								END
							ELSE
								BEGIN
									RETURN 2
								END
					
				END				
		END
GO
