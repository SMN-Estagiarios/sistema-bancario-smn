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
										EXEC [dbo].[SPJOB_CriarLancamentoEmprestimo]
										SELECT *
											FROM [dbo].[Parcela]
									ROLLBACK TRAN
		*/
	BEGIN
		--Declarar as vari�veis
		DECLARE @Id_Lancamento INT,
				@Id_Emprestimo INT,
				@Tipo_Lancamento TINYINT
		--Atribuir valor �s vari�veis
		SELECT	@Id_Lancamento = i.Id,
				@Tipo_Lancamento = i.Id_TipoLancamento,
				@Id_Emprestimo = e.Id
			FROM INSERTED i 
				INNER JOIN [dbo].[Emprestimo] e
					ON e.Id_Conta = i.Id_Conta
		--Atualizar registro de parcela caso o tipo do lan�amento seja empr�stimo
		IF(@Tipo_Lancamento = 8)
			BEGIN
				UPDATE [dbo].[Parcela]
					SET Id_Lancamento = @Id_Lancamento
					WHERE	Id_Emprestimo = @Id_Emprestimo
							AND DATEPART(MONTH, Data_Cadastro) = DATEPART(MONTH, GETDATE())
						
				--Retornar erro caso mais de uma linha seja atualizada
				IF @@ROWCOUNT <> 1
					BEGIN
						RAISERROR('Mais de um registro foi alterado', 16, 1)
					END
			END
	END
GO