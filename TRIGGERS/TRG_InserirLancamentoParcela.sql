CREATE OR ALTER TRIGGER [dbo].[TRG_InserirLancamentoParcela]
	ON [dbo].[Lancamentos]
	FOR INSERT
	AS
		/*
			Documenta��o
			Arquivo Fonte.........:	TRG_AtualizarParcela.sql
			Objetivo..............:	Atualizar o registro de parcela para popular a coluna do Id do lan�amento
			Autor.................: Odlavir Florentino, Rafael Mauricio e Jo�o Victor
			Data..................: 29/04/2024
			Ex....................: BEGIN TRAN
										
									ROLLBACK TRAN
		*/
	BEGIN
		DECLARE @Id_Lancamento INT, 
				@Tipo_Lancamento TINYINT,
				@Id_Emprestimo INT
		--Montar o cursor de lan�amentos
		DECLARE Lancamento CURSOR FOR
			SELECT	Id_Lancamento = i.Id,
					Tipo_Lancamento = i.Id_TipoLancamento,
					Id_Emprestimo = e.Id
				FROM INSERTED i WITH(NOLOCK)
					INNER JOIN [dbo].[Emprestimo] e WITH(NOLOCK)
						ON e.Id_Conta = i.Id_Conta

		--Abrir o Cursor
		OPEN Lancamento

		--Pegar registro
		FETCH NEXT FROM Lancamento
			INTO @Id_Lancamento, @Tipo_Lancamento, @Id_Emprestimo

		--Loop no cursor
		WHILE @@FETCH_STATUS = 0
			BEGIN
				--Atualizar o Id do lan�amento da parcela
				UPDATE TOP(1) [dbo].[Parcela]
					SET Id_Lancamento = @Id_Lancamento
					WHERE	Id_Lancamento IS NULL
							AND Id_Emprestimo = @Id_Emprestimo
				--Pegar pr�ximo registro
				FETCH NEXT FROM Lancamento
					INTO @Id_Lancamento, @Tipo_Lancamento, @Id_Emprestimo
			END
		--Fechar cursor
		CLOSE Lancamento
		DEALLOCATE Lancamento
	END
GO