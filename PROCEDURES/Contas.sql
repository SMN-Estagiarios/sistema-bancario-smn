USE SistemaBancario
GO

CREATE OR ALTER PROCEDURE [dbo].[SP_ListarSaldoAtual]
		@Id_Conta INT = NULL
		AS 
			/*
			Documenta��o
			Arquivo Fonte.....: Contas.sql
			Objetivo..........: Listar o saldo atual de todas as contas ou uma conta espec�fica
			Autor.............: Adriel Alexsander 
 			Data..............: 02/04/2024
			ObjetivoAlt.......: N/A
			AutorAlt..........: N/A
			DataAlt...........: N/A
			Ex................:  DECLARE @RET INT, 
						         @Dat_init DATETIME = GETDATE()

								 EXEC @RET = [dbo].[SP_ListarSaldoAtual
								 
								 SELECT @RET AS RETORNO,
										DATEDIFF(millisecond, @Dat_init, GETDATE()) AS EXECU��O 	
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
		Documenta��o
		Arquivo Fonte.....: Contas.sql
		Objetivo..........: Exclui uma conta existente com base no seu Id
		Autor.............: Adriel Alexsander 
 		Data..............: 02/04/2024
		ObjetivoAlt.......: N/A
		AutorAlt..........: N/A
		DataAlt...........: N/A
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

									EXEC @RET = [SP_ExcluirConta]1
									SELECT @RET AS RETORNO,
										   DATEDIFF(millisecond, @Dat_init, GETDATE()) AS EXECU��O 	

									SELECT  Id,
											Id_Usuario,
											Vlr_SldInicial,
											Vlr_Credito,
											Vlr_Debito,
											Dat_Saldo 
										FROM [dbo].[Contas]
							ROLLBACK TRAN
						--	RETORNO  --
							00.................: Sucesso
							01.................: Conta n�o existe
							02.................: Conta possui Lan�amentos         
	   */
		BEGIN
		--Checar se o Id da conta existe dentro do Banco
			IF NOT EXISTS( SELECT TOP 1 1
								FROM [dbo].[Contas] C WITH(NOLOCK)
								WHERE C.Id = @Id_Conta)
				BEGIN 
					PRINT 'Conta N�o Existe'
					RETURN 1
				END
		--Se existe Lan�amentos para essa Conta
		    IF EXISTS (SELECT TOP 1 1
								FROM [dbo].[Lancamentos] L WITH(NOLOCK)
								WHERE L.Id_Cta = @Id_Conta)
				BEGIN
					PRINT 'Conta possui lan�amentos'
					RETURN 2
				END
			ELSE
				BEGIN
					DELETE FROM [dbo].[Contas] 
						   WHERE Id = @Id_Conta
						   PRINT 'Sucesso'
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
										Id_Usuario,
										Vlr_SldInicial,
										Vlr_Credito,
										Vlr_Debito,
										Dat_Saldo 
									FROM [dbo].[Contas]

									EXEC @RET = [dbo].[SP_AtualizarConta] 1, Credito , 200

									SELECT @RET AS RETORNO,
											DATEDIFF(millisecond, @Dat_init, GETDATE()) AS TempoExecucao

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
								01.................: Conta n�o existe
								02.................: Valores nulo nos parametros passados  
								03.................: Valor do par�metro @Campo Invalido
								04.................: Valor do par�metro @Vlr_Atualizacao Invalido
*/
		BEGIN
			--Verificar se a conta existe
			IF NOT EXISTS( SELECT TOP 1 1
									FROM [dbo].[Contas] C WITH(NOLOCK)
									WHERE C.Id = @Id_Conta)
					BEGIN 
						PRINT 'Conta N�o Existe'
						RETURN 1
					END	
			--Verificar se as vari�veis passadas n�o s�o nulas
			IF(@Id_Conta IS NULL OR @Campo IS NULL OR @Vlr_Atualizacao IS NULL)
				BEGIN
					PRINT 'Valores de par�metro n�o podem ser nulos'
					RETURN 2
				END
			IF(@Campo NOT LIKE 'Cr[e�]dito' AND @Campo NOT LIKE 'D[e�]bito')
				BEGIN
					PRINT 'Deve-se inserir em campo Credito ou Debito'
					RETURN 3
				END
			IF (@Vlr_Atualizacao is null or @Vlr_Atualizacao <0)
				BEGIN 
					PRINT 'Valor n�o pode ser nulo ou negativo'
					RETURN 4
				END 
			ELSE
				BEGIN		-- atualiza a conta com base no ID 
					UPDATE [dbo].[Contas] 
						SET  Vlr_Credito = CASE WHEN @Campo LIKE 'Cr[�e]dito' THEN  @Vlr_Atualizacao ELSE Vlr_Credito END,
							 Vlr_Debito = CASE WHEN @Campo LIKE 'D[e�]bito' THEN  @Vlr_Atualizacao ELSE Vlr_Debito END
						WHERE Id = @Id_Conta
						PRINT 'Sucesso'
						RETURN 0
				END
		END
GO

CREATE OR ALTER PROCEDURE [dbo].[SP_InserirNovaConta] 
	@Id_Correntista INT
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

								EXEC @RET = [dbo].[SP_InserirNovaConta] 1

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
			
				
		INSERT INTO Contas(Id_Correntista, Vlr_SldInicial, Vlr_Credito, Vlr_Debito, Dat_Saldo, Dat_Abertura, Ativo, Lim_ChequeEspecial) 
		VALUES
			(@Id_Correntista, 0, 0, 0, GETDATE(), GETDATE(), 1, 0);

		IF @@ROWCOUNT <> 0
			RETURN 1
		ELSE
			RETURN 0
				
	END
GO

SELECT * FROM Contas
