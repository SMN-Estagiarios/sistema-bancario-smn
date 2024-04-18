CREATE OR ALTER PROCEDURE [dbo].[SP_CriarLancamentos]
		@Id_Cta INT,
		@Id_Usuario INT,
		@Id_Tarifa INT,
		@Tipo_Lanc CHAR(1),
		@Vlr_Lanc DECIMAL(15,2),
		@Nom_Historico VARCHAR(500),
		@Dat_Lancamento DATE,
		@Estorno BIT
	AS
		/*
			Documentação
			Arquivo Fonte.....: Lancamentos.sql
			Objetivo..........: Inserir Dados na Tabela Lançamentos, e não permitir lançamentos futuros
			Autor.............: Orcino Neto, Isabella Siqueira, Thays Carvalho
 			Data..............: 18/04/2024
			Ex................:	
									BEGIN TRAN
									DBCC DROPCLEANBUFFERS; 
									DBCC FREEPROCCACHE;

									DECLARE @Dat_init DATETIME = GETDATE(),
                                            @RET INT
									SELECT TOP 10 * FROM Lancamentos

									EXEC @RET = [dbo].[SP_CriarLancamentos]	1, 1, 1, 'C', 100, 'Deposito', GETDATE(), 0
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
		IF @Dat_Lancamento > GETDATE()
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
			INSERT INTO [dbo].[Lancamentos]  (Id_Cta,Id_Usuario,Id_Tarifa,Tipo_Lanc,Vlr_Lanc,Nom_Historico,Dat_Lancamento,Estorno) VALUES 
																(@Id_Cta, @Id_Usuario, @Id_Tarifa,@Tipo_Lanc,@Vlr_Lanc,	@Nom_Historico,@Dat_Lancamento,@Estorno)
            IF @@ROWCOUNT <> 0
                RETURN 0 
            ELSE 
                RETURN 4
	END;