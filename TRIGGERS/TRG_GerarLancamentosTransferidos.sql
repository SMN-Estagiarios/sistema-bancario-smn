CREATE OR ALTER TRIGGER [dbo].[TRG_GerarLancamentosTransferidos]
ON [dbo].[Transferencias]
FOR INSERT, DELETE, UPDATE
	AS
		/*
		DOCUMENTAÇÃO
		Arquivo Fonte........:	TRG_GerarLancamentosTransferidos.sql
		Objetivo.............:	gera inserts para transferência entre contas na tabela [dbo].[Lancamentos]
		Autor................:	Adriel Alexander
		Data.................:	05/04/2024
		Ex...................:		BEGIN TRAN
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
				@Id_TipoLancamento INT, 
				@Id_Tarifa TINYINT = NULL,
				@Vlr_Transferencia DECIMAL(15,2),
				@Nom_Referencia VARCHAR(200), 
				@Dat_Transferencia DATETIME,
				@Estorno BIT
				

	IF EXISTS (SELECT TOP 1 1 From inserted)
		BEGIN
		-- atribui��o de valores para casos de Insert
			SELECT @Id_Transferencia = Id,
				   @Id_ContaCre = Id_CtaCre,
				   @Id_ContaDeb = Id_CtaDeb, 
				   @Id_Usuario = Id_Usuario,
				   @Vlr_Transferencia = Vlr_Trans,
				   @Nom_Referencia = Nom_Referencia,
				   @Dat_Transferencia = Dat_Trans   
				FROM inserted 

			SET @Estorno = 0;
			IF(@Id_Transferencia IS NOT NULL)
				BEGIN
					SET @Id_TipoLancamento = 4 --- atribuindo o id da transferência enviada

				--inser��o do lan�amento para a conta que est� transferindo 
					INSERT INTO Lancamentos (Id_Cta, Id_Usuario, Id_TipoLancamento, Id_Tarifa, Tipo_Operacao, Vlr_Lanc, Nom_Historico, Dat_Lancamento, Estorno )VALUES
											(@Id_ContaDeb, @Id_Usuario, @Id_TipoLancamento, @Id_Tarifa,'D', @Vlr_Transferencia, CONCAT(@Nom_Referencia,' Código Transferência: ', @Id_Transferencia), @Dat_Transferencia, @Estorno)
					
					SET @Id_TipoLancamento = 3 --- atribuindo o id da transferência recebida
			
				--inser��o do lancamento para a conta que est� recebendo a transferencia
					INSERT INTO Lancamentos (Id_Cta, Id_Usuario, Id_TipoLancamento, Id_Tarifa, Tipo_Operacao, Vlr_Lanc, Nom_Historico, Dat_Lancamento, Estorno )VALUES
								(@Id_ContaCre,@Id_Usuario,  @Id_TipoLancamento, @Id_Tarifa,'C',@Vlr_Transferencia, CONCAT(@Nom_Referencia,' Código Transferência: ', @Id_Transferencia), @Dat_Transferencia, @Estorno)
				END

		END

	IF EXISTS (SELECT TOP 1 1 FROM DELETED)
		BEGIN
		SELECT @Id_Transferencia = Id,
			   @Id_Usuario = Id_Usuario,
			   @Id_ContaCre = Id_CtaCre,
			   @Id_ContaDeb = Id_CtaDeb, 
			   @Dat_Transferencia = Dat_Trans,
			   @Vlr_Transferencia = Vlr_Trans,
			   @Nom_Referencia = Nom_Referencia
			FROM Deleted

		SET @Estorno = 1;
		--	Delete do Lan�amento de debito
		IF(@Id_Transferencia IS NOT NULL)
				BEGIN
					SET @Id_TipoLancamento = 11
				--insercao do lancamento ESTORNO para a conta que recebeu a transferencia
					INSERT INTO Lancamentos (Id_Cta, Id_Usuario, Id_TipoLancamento, Id_Tarifa, Tipo_Operacao, Vlr_Lanc, Nom_Historico, Dat_Lancamento, Estorno )VALUES
					(@Id_ContaCre, @Id_Usuario, @Id_TipoLancamento ,@Id_Tarifa, 'D', @Vlr_Transferencia, CONCAT('Estorno enviado: ', @Nom_Referencia, ' Código Transferencia desfeita: ', @Id_Transferencia), @Dat_Transferencia, @Estorno)
				--insercao do lancamento ESTORNO para a conta recebeu a transferencia
					INSERT INTO Lancamentos (Id_Cta, Id_Usuario, Id_TipoLancamento, Id_Tarifa, Tipo_Operacao, Vlr_Lanc, Nom_Historico, Dat_Lancamento, Estorno )VALUES
					(@Id_ContaDeb,@Id_Usuario, @Id_TipoLancamento,@Id_Tarifa,'C',@Vlr_Transferencia, CONCAT('Estorno recebido: ', @Nom_Referencia , ' Código Transferencia desfeita: ', @Id_Transferencia), @Dat_Transferencia,@Estorno)
					
				END
		END
END
