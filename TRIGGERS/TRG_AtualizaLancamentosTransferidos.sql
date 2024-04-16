CREATE OR ALTER TRIGGER [dbo].[TRG_AtualizaLancamentosTransferidos]
ON [dbo].[Trasferencia]
FOR INSERT, DELETE, UPDATE
	AS
		/*
		DOCUMENTAÇÃO
		Arquivo Fonte........:	TRG_AtualizaSaldo.sql
		Objetivo.............:	Atualizar Saldo da tabela [dbo].[Contas]
		Autor................:	Adriel Alexander
		Data.................:	05/04/2024
		ObjetivoAlt..........: 
		AutorAlt.............: 
		DataAlt..............: 
		Ex...................:		BEGIN TRAN
									DBCC DROPCLEANBUFFERS;
									DBCC FREEPROCCACHE;

									DECLARE @DATA_INI DATETIME = GETDATE();

									SELECT  *
										FROM [dbo].[Trasferencia] WITH(NOLOCK)
									SELECT * 
										FROM [dbo].[Lancamentos] WITH(NOLOCK)

									INSERT INTO Trasferencia VALUES( 1, 1, 2, 50, 'EXEMPLO', GETDATE())
									
									SELECT DATEDIFF(MILLISECOND,@DATA_INI,GETDATE()) AS Execução

									SELECT  *
										FROM [dbo].[Trasferencia] WITH(NOLOCK)
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
				@Id_Tarifa TINYINT,
				@Vlr_Transferencia DECIMAL(15,2),
				@Nom_Referencia VARCHAR(200), 
				@Dat_Transferencia DATETIME

		SELECT  @Id_Tarifa = Id
						FROM Tarifas
						WHERE Nome = 'TEC'

	IF EXISTS (SELECT TOP 1 1 From inserted)
		BEGIN
		-- atribui��o de valores para casos de Insert
			SELECT @Id_Transferencia = Id,
				   @Id_ContaCre = Id_CtaCre,
				   @Id_ContaDeb = Id_CtaDeb, 
				   @Id_Usuario = Id_Usuario,
				   @Vlr_Transferencia = Vlr_TRans,
				   @Nom_Referencia = Nom_Referencia,
				   @Dat_Transferencia = Dat_Trans
				FROM inserted 
			IF(@Id_Transferencia IS NOT NULL)
				BEGIN
				--inser��o do lan�amento para a conta que est� transferindo 
					INSERT INTO Lancamentos VALUES(@Id_ContaDeb, @Id_Usuario,  @Id_Tarifa,'D', @Vlr_Transferencia, @Nom_Referencia, @Dat_Transferencia)
				--inser��o do lancamento para a conta que est� recebendo a transferencia
					INSERT INTO Lancamentos VALUES(@Id_ContaCre,@Id_Usuario,   @Id_Tarifa,'C',@Vlr_Transferencia, @Nom_Referencia, @Dat_Transferencia)
				END

		END

	IF EXISTS (SELECT TOP 1 1 FROM DELETED)
		BEGIN
		SELECT @Id_Transferencia = Id,
			   @Id_Usuario = Id_Usuario,
			   @Id_ContaCre = Id_CtaCre,
			   @Id_ContaDeb = Id_CtaDeb, 
			   @Dat_Transferencia = Dat_Trans,
			   @Vlr_Transferencia = Vlr_TRans,
			   @Nom_Referencia = Nom_Referencia
			FROM Deleted
		--	Delete do Lan�amento de debito
		IF(@Id_Transferencia IS NOT NULL)
				BEGIN
				--insercao do lancamento para a conta que esta transferindo 
					INSERT INTO Lancamentos VALUES(@Id_ContaCre, @Id_Usuario,@Id_Tarifa, 'D', @Vlr_Transferencia, CONCAT('Estorno enviado: ', @Nom_Referencia), @Dat_Transferencia)
				--insercao do lancamento para a conta que esta recebendo a transferencia
					INSERT INTO Lancamentos VALUES(@Id_ContaDeb,@Id_Usuario, @Id_Tarifa,'C',@Vlr_Transferencia, CONCAT('Estorno recebido: ', @Nom_Referencia), @Dat_Transferencia)
					
				END
		END
 END