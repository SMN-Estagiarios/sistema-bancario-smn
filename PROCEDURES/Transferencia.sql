CREATE OR ALTER PROC [dbo].[SP_RealizarNovaTransferenciaBancaria]
	@Id_Usuario INT,
	@Id_ContaDeb INT,
	@Id_ContaCre INT,
	@Vlr_Tranferencia DECIMAL(15,2),
	@Nom_referencia VARCHAR(200)
	AS
	/*
			Documentação
			Arquivo Fonte.....: Transfencia.sql
			Objetivo..........: Instancia uma nova trasnferência entre contas
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
											Vlr_debito,
											Dat_Saldo
									FROM [dbo].[Contas]

								 EXEC [SP_RealizarNovaTransferenciaBancaria] 1,15, 16,  300, 'EXEMPLO' 

									SELECT @RET AS RETORNO,
										   DATEDIFF(millisecond, @Dat_init, GETDATE()) AS EXECUÇÃO
									SELECT  Id,
											Id_Usuario,
											Vlr_SldInicial, 
											Vlr_Credito,
											Vlr_debito,
											Dat_Saldo
									FROM [dbo].[Contas]
						   ROLLBACK TRAN

							-- RETORNO --
							
							00.................: Sucesso
							01.................: Conta não existe
							02.................: Conta possui Lançamentos   
	*/
	BEGIN
		--Verifica se as contas Existem
		IF NOT EXISTS (SELECT TOP 1 1
								FROM [dbo].[Contas]
								WHERE Id  = @Id_ContaCre)
			BEGIN
				PRINT 'conta credito não existem'
				RETURN 1
			END
		IF NOT EXISTS (SELECT TOP 1 1
								FROM [dbo].[Contas]
								WHERE 	Id = @Id_ContaDeb)
			BEGIN
				PRINT 'conta credito não existem'
				RETURN 1
			END
		--Verifica se o valor da transferência é inferior ao valor de saldo
		IF(@Vlr_Tranferencia > (SELECT [dbo].[Func_CalculaSaldoAtual](@Id_ContaDeb, Vlr_SldInicial, Vlr_Credito,Vlr_Debito)
										FROM Contas 
										WHERE Id = @Id_ContaDeb )) 
			BEGIN
				PRINT 'Saldo insuficiênte para realização da Transferência'
				RETURN 2
			END
		-- Verifica o usuario da conta
		IF NOT EXISTS (SELECT TOP 1 1 
							FROM [dbo].[Usuarios] 
							WHERE Id = @Id_Usuario)
			BEGIN
				PRINT 'USUARIO NÃO ENCONTRADO'
				RETURN 3
			END
			--validação de uma trasnferência entre contas feitas para uma mesma conta 
		IF(@Id_ContaDeb = @Id_ContaCre)
			BEGIN 
				PRINT 'Impossível transferir para a mesma conta'
				RETURN 4
			END
		--Gerar Inserts em transferência
	    ELSE
			BEGIN
				INSERT INTO Trasferencia VALUES( @Id_Usuario, @Id_ContaCre, @Id_ContaDeb, @Vlr_Tranferencia, @Nom_referencia, GETDATE())
			END
		RETURN 0
	END
