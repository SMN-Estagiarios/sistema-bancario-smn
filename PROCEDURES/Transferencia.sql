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
										   DATEDIFF(millisecond, @Dat_init, GETDATE()) AS EXECU��O
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
							01.................: Conta n�o existe
							02.................: Conta possui Lan�amentos   
	*/
	BEGIN
		--Verifica se as contas Existem
		IF NOT EXISTS (SELECT TOP 1 1
								FROM [dbo].[Contas]
								WHERE Id  = @Id_ContaCre)
			BEGIN
				PRINT 'conta credito n�o existem'
				RETURN 1
			END
		IF NOT EXISTS (SELECT TOP 1 1
								FROM [dbo].[Contas]
								WHERE 	Id = @Id_ContaDeb)
			BEGIN
				PRINT 'conta credito n�o existem'
				RETURN 1
			END
		--Verifica se o valor da transfer�ncia � inferior ao valor de saldo
		IF(@Vlr_Tranferencia > (SELECT [dbo].[Func_CalculaSaldoAtual](@Id_ContaDeb, Vlr_SldInicial, Vlr_Credito,Vlr_Debito)
										FROM Contas 
										WHERE Id = @Id_ContaDeb )) 
			BEGIN
				PRINT 'Saldo insufici�nte para realiza��o da Transfer�ncia'
				RETURN 2
			END
		-- Verifica o usuario da conta
		IF NOT EXISTS (SELECT TOP 1 1 
							FROM [dbo].[Usuarios] 
							WHERE Id = @Id_Usuario)
			BEGIN
				PRINT 'USUARIO N�O ENCONTRADO'
				RETURN 3
			END
			--valida��o de uma trasnfer�ncia entre contas feitas para uma mesma conta 
		IF(@Id_ContaDeb = @Id_ContaCre)
			BEGIN 
				PRINT 'Imposs�vel transferir para a mesma conta'
				RETURN 4
			END
		--Gerar Inserts em transfer�ncia
	    ELSE
			BEGIN
				INSERT INTO Trasferencia VALUES( @Id_Usuario, @Id_ContaCre, @Id_ContaDeb, @Vlr_Tranferencia, @Nom_referencia, GETDATE())
			END
		RETURN 0
	END
CREATE OR ALTER PROC [dbo].[SP_RealizarEstornoTransferencia]
	@Id_Transferencia INT

	AS

	--DOCUMENTA��O

	BEGIN
			IF Id_Transferencia IS NOT NULL

				BEGIN
					IF NOT EXISTS (SELECT TOP 1 1
						FROM [dbo].[Transferencia] WITH (NOLOCK)
						WHERE Id = Id_Transferencia)
						BEGIN
							RETURN 1
						END

					DELETE Transferencias
						WHERE Id = @Id_Transferencia
						RETURN 0
				END
			ELSE
				BEGIN
					RETURN 2
				END
	END

CREATE OR ALTER PROC [dbo].[SP_ListarExtratoTransferencia]
	@Id_Conta INT

	AS
	-- documenta��o

	BEGIN
		SELECT
			Id_Cta AS Id_Conta,
			Dat_Lancamento AS Data_Transfer�ncia,
			Vlr_Lanc AS Vlr_Transfer�ncia,
			Nom_Historico AS Descrição
				FROM [dbo].[Lancamentos] WITH (NOLOCK)
				WHERE Id_Cta IS NULL (@IdConta, Id_Cta)
				AND Id_Tarifa = (SELECT 
									ID
									FROM Tarifa
									WHERE Nome = 'TEC')
	END
