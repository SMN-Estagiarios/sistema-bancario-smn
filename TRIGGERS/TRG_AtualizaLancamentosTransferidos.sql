CREATE OR ALTER TRIGGER [dbo].[TRG_AtualizaLancamentosTransferidos]
ON [dbo].[Trasferencia]
FOR INSERT, DELETE, UPDATE
	AS
		/*
		DOCUMENTACAO
	
		*/
		--Declaracao de Variáveis 
 BEGIN
		DECLARE @Id_Trasferencia INT,
				@Id_ContaCre INT,
				@Id_ContaDeb INT,
				@Id_Usuario INT, 
				@Vlr_Transferencia DECIMAL(15,2),
				@Nom_Referencia VARCHAR(200), 
				@Dat_Transferencia DATETIME

	IF EXISTS (SELECT TOP 1 1 From inserted)
		BEGIN
		-- atribuição de valores para casos de Insert
			SELECT @Id_Trasferencia = Id,
				   @Id_ContaCre = Id_CtaCre,
				   @Id_ContaDeb = Id_CtaDeb, 
				   @Id_Usuario = Id_Usuario,
				   @Vlr_Transferencia = Vlr_TRans,
				   @Nom_Referencia = Nom_Referencia,
				   @Dat_Transferencia = Dat_Trans
				FROM inserted 
			IF(@Id_Trasferencia IS NOT NULL)
				BEGIN
				--inserção do lançamento para a conta que está transferindo 
					INSERT INTO Lancamentos VALUES(@Id_ContaDeb, @Id_Usuario, 'D', @Vlr_Transferencia, @Nom_Referencia, @Dat_Transferencia)
				--inserção do lancamento para a conta que está recebendo a transferencia
					INSERT INTO Lancamentos VALUES(@Id_ContaCre,@Id_Usuario, 'C',@Vlr_Transferencia, @Nom_Referencia, @Dat_Transferencia)
				END

		END
--IF EXISTS (SELECT TOP 1 1 FROM DELETED)
--		BEGIN
	--		SELECT @Id_Trasferencia = Id,
	--			   @Id_ContaCre = Id_CtaCre,
	--			   @Id_ContaDeb = Id_CtaDeb, 
	--			   @Dat_Transferencia = Dat_Trans
	--			FROM Deleted
	--		-- Delete do Lançamento de debito
	--		DELETE Lancamentos 
	--			WHERE Id_Cta =  @Id_ContaDeb 
	--				AND Dat_Lancamento = @Dat_Transferencia 
	--				AND Tipo_Lanc = 'D'
	--	   --Deletando o lançamento de Credito
	--	   DELETE Lancamentos 
	--			WHERE Id_Cta =  @Id_ContaCre 
	--				AND Dat_Lancamento = @Dat_Transferencia 
	--				AND Tipo_Lanc = 'C'
	--	END
	IF EXISTS (SELECT TOP 1 1 FROM DELETED)
		BEGIN
		SELECT @Id_Trasferencia = Id,
			   @Id_Usuario = Id_Usuario,
			   @Id_ContaCre = Id_CtaCre,
			   @Id_ContaDeb = Id_CtaDeb, 
			   @Dat_Transferencia = Dat_Trans,
			   @Vlr_Transferencia = Vlr_TRans,
			   @Nom_Referencia = Nom_Referencia
			FROM Deleted
		--	Delete do Lançamento de debito
		IF(@Id_Trasferencia IS NOT NULL)
				BEGIN
				--inserção do lançamento para a conta que está transferindo 
					INSERT INTO Lancamentos VALUES(@Id_ContaCre, @Id_Usuario, 'D', @Vlr_Transferencia, @Nom_Referencia, @Dat_Transferencia)
				--inserção do lancamento para a conta que está recebendo a transferencia
					INSERT INTO Lancamentos VALUES(@Id_ContaDeb,@Id_Usuario, 'C',@Vlr_Transferencia, @Nom_Referencia, @Dat_Transferencia)
					
				END
		END
 END