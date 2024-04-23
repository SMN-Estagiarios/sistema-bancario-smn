USE SistemaBancario
GO

CREATE OR ALTER TRIGGER [dbo].[TRG_GerarLancamentosTransferidos]
ON [dbo].[Transferencias]
FOR INSERT, DELETE, UPDATE
	AS
		/*
		DOCUMENTAÇÃO
		Arquivo Fonte........:	TRG_GerarLancamentosTransferidos.sql
		Objetivo.............:	gera inserts na tabela de lancamentos mediante transferencias cadastradas 
								travado código para id_tipoLancamento para transferencias entre contas recebidas = 3, enviadas =4 e estorno = 11
		Autor................:	Adriel Alexander
		Data.................:	05/04/2024
		Ex...................:	BEGIN TRAN
									DBCC DROPCLEANBUFFERS;
									DBCC FREEPROCCACHE;

									DECLARE @DATA_INI DATETIME = GETDATE();

									SELECT  *
										FROM [dbo].[Transferencias] WITH(NOLOCK)
									SELECT * 
										FROM [dbo].[Lancamentos] WITH(NOLOCK)

									INSERT INTO Transferencias VALUES( 1, 1, 2, 50, 'EXEMPLO', GETDATE())
									
									SELECT DATEDIFF(MILLISECOND,@DATA_INI,GETDATE()) AS Execução

									SELECT  *
										FROM [dbo].[Transferencias] WITH(NOLOCK)
									SELECT * 
										FROM [dbo].[Lancamentos] WITH(NOLOCK)
								ROLLBACK TRAN
	
		*/
	BEGIN
		--Declaracao de Variáveis 
		DECLARE @Id_Transferencia INT,
				@Id_ContaCre INT,
				@Id_ContaDeb INT,
				@Id_Usuario INT, 
				@Vlr_Transferencia DECIMAL(15,2),
				@Nom_Referencia VARCHAR(200), 
				@Dat_Transferencia DATETIME,
				@TipoLancamento = 3

	   	-- atribui��o de valores para casos de Insert
		SELECT  @Id_Transferencia = Id,
				@Id_ContaCre = Id_CtaCre,
				@Id_ContaDeb = Id_CtaDeb, 
				@Id_Usuario = Id_Usuario,
				@Vlr_Transferencia = Vlr_Trans,
				@Nom_Referencia = Nom_Referencia,
				@Dat_Transferencia = Dat_Trans   
			FROM inserted 		

		IF @Id_Transferencia IS NOT NULL
			BEGIN	
				--inser��o do lan�amento para a conta que est� transferindo 
				INSERT INTO [dbo].[Lancamentos] (Id_Cta, Id_Usuario, Id_TipoLancamento, Tipo_Operacao, Vlr_Lanc, Nom_Historico, Dat_Lancamento, Estorno )VALUES
										(@Id_ContaDeb, @Id_Usuario, @TipoLancamento,'D', @Vlr_Transferencia, CONCAT(@Nom_Referencia,' Código Transferência: ', @Id_Transferencia), @Dat_Transferencia, 0)
					
				IF @@ERROR <> 0 OR @@ROWCOUNT <> 1
					BEGIN 
						RAISERROR('Erro na inclusão do lancamento de Débito', 16,1)
					END
				--inser��o do lancamento para a conta que est� recebendo a transferencia
				INSERT INTO [dbo].[Lancamentos] (Id_Cta, Id_Usuario, Id_TipoLancamento, Tipo_Operacao, Vlr_Lanc, Nom_Historico, Dat_Lancamento, Estorno )VALUES
							(@Id_ContaCre,@Id_Usuario,  @TipoLancamento,'C',@Vlr_Transferencia, CONCAT(@Nom_Referencia,' Código Transferência: ', @Id_Transferencia), @Dat_Transferencia, 0)
				
				IF @@ERROR <> 0 OR @@ROWCOUNT <> 1
					BEGIN 
						RAISERROR('Erro na inclusão do lancamento de Crédito', 16,1)
					END
			END
		SET @Id_Transferencia = NULL 

		SELECT	@Id_Transferencia = Id,
				@Id_Usuario = Id_Usuario,
				@Id_ContaCre = Id_CtaCre,
				@Id_ContaDeb = Id_CtaDeb, 
				@Dat_Transferencia = Dat_Trans,
				@Vlr_Transferencia = Vlr_Trans,
				@Nom_Referencia = Nom_Referencia
			FROM Deleted

		--	Delete do Lan�amento de debito
		IF @Id_Transferencia IS NOT NULL
				BEGIN
					--insercao do lancamento ESTORNO para a conta que recebeu a transferencia
					INSERT INTO [dbo].[Lancamentos] (Id_Cta, Id_Usuario, Id_TipoLancamento, Tipo_Operacao, Vlr_Lanc, Nom_Historico, Dat_Lancamento, Estorno )VALUES
						(@Id_ContaCre, @Id_Usuario, @TipoLancamento , 'D', @Vlr_Transferencia, CONCAT('Estorno enviado: ', @Nom_Referencia, ' Código Transferencia desfeita: ', @Id_Transferencia), @Dat_Transferencia, 1)

					IF @@ERROR <> 0 OR @@ROWCOUNT <> 1
						BEGIN 
							RAISERROR('Erro na inclusão do lancamento de estorno de Débito', 16,1)
						END
						--insercao do lancamento ESTORNO para a conta recebeu a transferencia
					INSERT INTO [dbo].[Lancamentos] (Id_Cta, Id_Usuario, Id_TipoLancamento, Tipo_Operacao, Vlr_Lanc, Nom_Historico, Dat_Lancamento, Estorno )VALUES
						(@Id_ContaDeb,@Id_Usuario, @TipoLancamento,'C',@Vlr_Transferencia, CONCAT('Estorno recebido: ', @Nom_Referencia , ' Código Transferencia desfeita: ', @Id_Transferencia), @Dat_Transferencia,1)

					 IF @@ERROR <> 0 OR @@ROWCOUNT <> 1
						BEGIN 
							RAISERROR('Erro na inclusão do lancamento de estorno de Crédito', 16,1)
						END
				END
	END
