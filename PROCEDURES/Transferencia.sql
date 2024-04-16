CREATE OR ALTER PROC [dbo].[SP_RealizarNovaTransferenciaBancaria]
	@Id_Usuario INT,
	@Id_ContaDeb INT,
	@Id_ContaCre INT,
	@Vlr_Tranferencia DECIMAL(15,2),
	@Nom_referencia VARCHAR(200)
	AS
	/* 
			Documenta��o
			Arquivo Fonte.....: Transfencia.sql
			Objetivo..........: Instancia uma nova trasnfer�ncia entre contas
			Autor.............: Adriel Alexsander, Thays Carvalho, Isabella Tragante
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
											Vlr_SldInicial, 
											Vlr_Credito,
											Vlr_debito,
											Dat_Saldo
									FROM [dbo].[Contas]

									SELECT * from Lancamentos

								 EXEC @RET = [SP_RealizarNovaTransferenciaBancaria] 1,1, 2,  50, 'Transfe pagamento aluguel' 

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
		IF(@Vlr_Tranferencia > (SELECT [dbo].[Func_CalculaSaldoAtual](@Id_ContaDeb, Vlr_SldInicial, Vlr_Credito,Vlr_Debito)
										FROM Contas 
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
			--validacao de uma trasnferencia entre contas feitas para uma mesma conta 
		IF(@Id_ContaDeb = @Id_ContaCre)
			BEGIN 
				RETURN 4
			END
		--Gerar Inserts em transfer�ncia
	    ELSE
			BEGIN
				INSERT INTO Trasferencia VALUES( @Id_Usuario, @Id_ContaCre, @Id_ContaDeb, @Vlr_Tranferencia, @Nom_referencia, GETDATE())
			END
		RETURN 0
	END
GO
CREATE OR ALTER PROC [dbo].[SP_RealizarEstornoTransferencia]
	@Id_Transferencia INT

	AS

	/*
			Documentação
			Arquivo Fonte.....: Transfencia.sql
			Objetivo..........: Instancia uma nova trasnferência entre contas
			Autores...........: Adriel Alexsander, Thays Carvalho, Isabella Tragante
 			Data..............: 12/04/2024
			ObjetivoAlt.......: N/A
			AutorAlt..........: N/A
			DataAlt...........: N/A
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

									SELECT * from Lancamentos

								  EXEC @RET = [dbo].[SP_RealizarEstornoTransferencia]12

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
	*/
	BEGIN
			--varificação de Id da trasnferência passada como parâmetro
			IF @Id_Transferencia IS NOT NULL

				BEGIN
					--validação para saber se o numero de id passada existe na tabela trasferencia
					IF NOT EXISTS (SELECT TOP 1 1
										FROM [dbo].[Trasferencia] WITH (NOLOCK)
										WHERE Id = @Id_Transferencia)
						BEGIN
							RETURN 1
						END
					--efetuando a deleção de registro de trasnferência para disparo do trigger
					DELETE Trasferencia
						WHERE Id = @Id_Transferencia
						RETURN 0
				END
			ELSE
				BEGIN
					RETURN 2
				END
	END
GO

CREATE OR ALTER PROC [dbo].[SP_ListarExtratoTransferencia]
	@Id_Conta INT = null

	AS
	/*
			Documentação
			Arquivo Fonte.....: Contas.sql
			Objetivo..........: Listar o saldo atual de todas as contas ou uma conta específica
			Autor.............: Adriel Alexsander 
 			Data..............: 02/04/2024
			ObjetivoAlt.......: N/A
			AutorAlt..........: N/A
			DataAlt...........: N/A
			Ex................:  DECLARE @RET INT, 
						         @Dat_init DATETIME = GETDATE()

								 EXEC @RET = [dbo].[SP_ListarExtratoTransferencia]
								 
								 SELECT @RET AS RETORNO,
										DATEDIFF(millisecond, @Dat_init, GETDATE()) AS EXECUÇÃO 	
	*/

	BEGIN
		SELECT
			Id_Cta AS Id_Conta,
			Dat_Lancamento AS Data_Transferencia,
			Vlr_Lanc AS Vlr_Transferencia,
			Nom_Historico AS Descrição
				FROM [dbo].[Lancamentos] WITH (NOLOCK)
				WHERE Id_Cta = ISNULL(@Id_Conta, Id_Cta)
				AND Id_Tarifa = (SELECT 
									ID
									FROM Tarifas
									WHERE Nome = 'TEC')
	END
GO