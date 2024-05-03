USE SistemaBancario
GO

CREATE OR ALTER PROCEDURE [dbo].[SP_RealizarNovaTransferenciaBancaria]
	@Id_Usuario INT,
	@Id_ContaDeb INT,
	@Id_ContaCre INT,
	@Vlr_Transferencia DECIMAL(15,2),
	@Nom_referencia VARCHAR(200)
	AS
	/* 
			Documentação
			Arquivo Fonte.....: Transferencia.sql
			Objetivo..........: Instancia uma nova trasnferência entre contas
			Autor.............: Adriel Alexsander, Thays Carvalho, Isabella Tragante
 			Data..............: 02/04/2024
			Ex................: BEGIN TRAN
								DBCC DROPCLEANBUFFERS;
								DBCC FREEPROCCACHE;

								DECLARE @RET INT, 
								@Dat_init DATETIME = GETDATE()

								SELECT  Id,
										Vlr_SldInicial, 
										Vlr_Credito,
										Vlr_debito,
										Dat_Saldo
								FROM [dbo].[Contas]


								EXEC @RET =  [SP_RealizarNovaTransferenciaBancaria] 0,1, 2,  50, 'Transfe pagamento aluguel' 

								SELECT @RET AS RETORNO,
										DATEDIFF(millisecond, @Dat_init, GETDATE()) AS EXECUcaO
								SELECT  Id,
										Vlr_SldInicial, 
										Vlr_Credito,
										Vlr_debito,
										Dat_Saldo
								FROM [dbo].[Contas]


								SELECT * from Lancamentos
									
						   ROLLBACK TRAN

							-- RETORNO --
							
							00.................: Sucesso
							01.................: Conta não existe
							02.................: Valor de saldo insuficiente 
							03.................: Usuario não existe
							04.................: impossivel fazer trasnferência para a mesma conta destino e origem
	*/
	BEGIN
		
		DECLARE @Data_Atual DATE = GETDATE()
		--Verifica se as contas Existem
		IF NOT EXISTS (SELECT TOP 1 1
								FROM [dbo].[Contas]
								WHERE Id  = @Id_ContaCre)
			BEGIN
				RETURN 1
			END
		IF NOT EXISTS (SELECT TOP 1 1
								FROM [dbo].[Contas]
								WHERE 	Id = @Id_ContaDeb)
			BEGIN
				RETURN 1
			END
		--Verifica se o valor da transferencia é inferior ao valor de saldo
		IF(@Vlr_Transferencia > (SELECT [dbo].[FNC_CalcularSaldoAtual](@Id_ContaDeb, Vlr_SldInicial, Vlr_Credito,Vlr_Debito)
										FROM [dbo].[Contas]
										WHERE Id = @Id_ContaDeb )) 
			BEGIN
				RETURN 2
			END
		-- Verifica o usuario da conta
		IF NOT EXISTS (SELECT TOP 1 1 
							FROM [dbo].[Usuarios] 
							WHERE Id = @Id_Usuario)
			BEGIN
				RETURN 3
			END
			--validacao de uma transferencia entre contas feitas para uma mesma conta 
		IF(@Id_ContaDeb = @Id_ContaCre)
			BEGIN 
				RETURN 4
			END
		--Gerar Inserts em transferência
	    ELSE
			BEGIN
				INSERT INTO [dbo].[Transferencias]	(
														Id_Usuario,
														Id_Conta_Credito,
														Id_Conta_Debito,
														Vlr_Trans,
														Nom_Referencia,
														Dat_Trans
													)
											VALUES
													(	
														@Id_Usuario, 
														@Id_ContaCre, 
														@Id_ContaDeb, 
														@Vlr_Transferencia, 
														@Nom_referencia, 
														@Data_Atual
													)
			END
		RETURN 0
	END
GO

CREATE OR ALTER PROCEDURE [dbo].[SP_RealizarEstornoTransferencia]
	@Id_Transferencia INT
	AS
	/*
			Documentação
			Arquivo Fonte.....: Transfencia.sql
			Objetivo..........: Instancia uma nova transferência entre contas
			Autores...........: Adriel Alexsander, Thays Carvalho, Isabella Tragante
 			Data..............: 12/04/2024
			EX.................:BEGIN TRAN
								DBCC DROPCLEANBUFFERS;
								DBCC FREEPROCCACHE;

								DECLARE @RET INT, 
								@Dat_init DATETIME = GETDATE()

									SELECT  Id,
											Vlr_SldInicial, 
											Vlr_Credito,
											Vlr_debito,
											Dat_Saldo
									FROM [dbo].[Contas]

									Select * from Transferencias
									SELECT * from Lancamentos

								  EXEC @RET = [dbo].[SP_RealizarEstornoTransferencia]15

									SELECT @RET AS RETORNO,
										   DATEDIFF(millisecond, @Dat_init, GETDATE()) AS EXECUcaO
									SELECT  Id,
											Vlr_SldInicial, 
											Vlr_Credito,
											Vlr_debito,
											Dat_Saldo
									FROM [dbo].[Contas]
									SELECT * from Lancamentos
									SELECT * from transferencias
								ROLLBACK TRAN
	*/
	BEGIN
			--varificação de Id da transferência passada como parâmetro
			IF @Id_Transferencia IS NOT NULL

				BEGIN
					--validação para saber se o numero de id passada existe na tabela transferencia
					IF NOT EXISTS (SELECT TOP 1 1
										FROM [dbo].[Transferencias] WITH (NOLOCK)
										WHERE Id = @Id_Transferencia)
						BEGIN
							RETURN 1
						END
					
					ALTER TABLE [dbo].[TransferenciasLancamentos]
					DROP CONSTRAINT [FK_IdTransferencia_TransferenciaLancamentos]
						
						DELETE [dbo].[Transferencias]
							WHERE Id = @Id_Transferencia
							RETURN 0

					ALTER TABLE [dbo].[TrasnferenciasLancamentos]
					ADD CONSTRAINT [FK_IdTransferencia_TransferenciaLancamentos] FOREIGN KEY (Id_Transferencia) REFERENCES Transferencias(Id);
				END
			ELSE
				BEGIN
					RETURN 2
				END
	END
GO

CREATE OR ALTER  PROCEDURE [dbo].[SP_RegistrarLancamentosTransferencia]
		@Id_Transferencia INT,
		@Id_Lancamentos INT 
	AS 
	/*
			Documentação
			Arquivo Fonte.....: Transferencia.sql
			Objetivo..........: Instancia uma nova trasnferência entre contas
			Autor.............: Adriel Alexsander, Thays Carvalho, Isabella Tragante
 			Data..............: 02/04/2024
			Autor Alteracao...: Adriel Alexander de Sousa
			Data Alteracao....: 29/04/2024
			Ex................: BEGIN TRAN
									DBCC DROPCLEANBUFFERS;
									DBCC FREEPROCCACHE;

									DECLARE @RET INT, 
									@Dat_init DATETIME = GETDATE()

									SELECT  Id,
											Vlr_SldInicial, 
											Vlr_Credito,
											Vlr_debito,
											Dat_Saldo
									FROM [dbo].[Contas]

									SELECT * FROM [dbo].[TransferenciasLancamentos]

									EXEC @RET =  [SP_RealizarNovaTransferenciaBancaria] 0,1, 2,  50, 'Transfe pagamento aluguel' 

									SELECT @RET AS RETORNO,
											DATEDIFF(millisecond, @Dat_init, GETDATE()) AS EXECUcaO
									SELECT  Id,
											Vlr_SldInicial, 
											Vlr_Credito,
											Vlr_debito,
											Dat_Saldo
									FROM [dbo].[Contas]

									SELECT * FROM [dbo].[TransferenciasLancamentos]

									SELECT * from Lancamentos
									
								ROLLBACK TRAN

		    EX2..............: BEGIN TRAN
									DBCC DROPCLEANBUFFERS;
									DBCC FREEPROCCACHE;

									DECLARE @RET INT, 
									@Dat_init DATETIME = GETDATE()

										SELECT  Id,
												Vlr_SldInicial, 
												Vlr_Credito,
												Vlr_debito,
												Dat_Saldo
										FROM [dbo].[Contas]

										Select * from Transferencias
										SELECT * from Lancamentos
										SELECT * from [dbo].[TransferenciasLancamentos]

									  EXEC @RET = [dbo].[SP_RealizarEstornoTransferencia]4

										SELECT @RET AS RETORNO,
											   DATEDIFF(millisecond, @Dat_init, GETDATE()) AS EXECUcaO
										SELECT  Id,
												Vlr_SldInicial, 
												Vlr_Credito,
												Vlr_debito,
												Dat_Saldo
										FROM [dbo].[Contas]
										SELECT * from Lancamentos
										SELECT * from transferencias
										SELECT * from [dbo].[TransferenciasLancamentos]
								ROLLBACK TRAN

							-- RETORNO --
							
							00.................: Sucesso
							01.................: Erro na inserção do lancamento
						
	*/ 
	 BEGIN
			BEGIN
				 INSERT INTO [dbo].[TransferenciasLancamentos](
															  IdTransferencia, 
															  IdLancamento
															 )
														VALUES
															 (
															 @Id_Transferencia, 
															 @Id_Lancamentos
															 )
				 IF @@ERROR <> 0 OR @@ROWCOUNT <> 1
					BEGIN 
						RAISERROR('Erro ao registrar o Lancamento Da Transferencia: ', 16,1)
						RETURN 1 
					END
				RETURN 0
			END
 
     END
GO 

CREATE OR ALTER PROCEDURE [dbo].[SP_ListarExtratoTransferencia]
	@Id_Conta INT = null
	AS
	/*
			Documentação
			Arquivo Fonte.....: Transferencia.sql
			Objetivo..........: Listar o extrato de transferência entre contas
			Autor.............: Adriel Alexsander 
 			Data..............: 02/04/2024
			Ex................:  DECLARE @RET INT, 
						         @Dat_init DATETIME = GETDATE()

								 EXEC @RET = [dbo].[SP_ListarExtratoTransferencia]1
								 
								 SELECT @RET AS RETORNO,
										DATEDIFF(millisecond, @Dat_init, GETDATE()) AS EXECUÇÃO 	
	*/
	BEGIN
		SELECT
			Id_Conta,
			Dat_Lancamento AS Data_Transferencia,
			Vlr_Lanc AS Vlr_Transferencia,
			Nom_Historico AS Descrição
				FROM [dbo].[Lancamentos] WITH (NOLOCK)
				WHERE Id_Conta =	ISNULL(@Id_Conta, Id_Conta) 
	END
GO
