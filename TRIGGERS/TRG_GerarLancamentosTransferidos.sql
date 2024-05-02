USE SistemaBancario
GO

CREATE OR ALTER TRIGGER [dbo].[TRG_GerarLancamentosTransferidos]
ON [dbo].[Transferencias]
FOR INSERT, DELETE
	AS
		/*
		DOCUMENTAÇÃO
		Arquivo Fonte........:	TRG_GerarLancamentosTransferidos.sql
		Objetivo.............:	gera inserts na tabela de lancamentos mediante transferencias cadastradas 
								travado código para id_tipoLancamento para transferencias = 3 Estorno travado em 0 e 1 para representar se a operação é estorno = 1
		Autor................:	Adriel Alexander
		Data.................:	05/04/2024
		Autor Alteração......:  Adriel Alexander De Sousa
		Data Alteracao.......:  29/04/2024
		Ex...................:	BEGIN TRAN
									DBCC DROPCLEANBUFFERS;
									DBCC FREEPROCCACHE;

									DECLARE @DATA_INI DATETIME = GETDATE();

									SELECT  *
										FROM [dbo].[Transferencias] WITH(NOLOCK)
									SELECT * 
										FROM [dbo].[Lancamentos] WITH(NOLOCK)

									INSERT INTO Transferencias VALUES( 0, 1, 2, 50, 'EXEMPLO', GETDATE())
									
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
					@TipoLancamento INT = 3, --id_tipolancamento travado em transferencia 
					@Id_LancamentoInserido INT

	   		-- atribui��o de valores para casos de Insert
			SELECT  @Id_Transferencia = Id,
					@Id_ContaCre = Id_Conta_Credito,
					@Id_ContaDeb = Id_Conta_Debito, 
					@Id_Usuario = Id_Usuario,
					@Vlr_Transferencia = Vlr_Trans,
					@Nom_Referencia = Nom_Referencia,
					@Dat_Transferencia = Dat_Trans   
				FROM inserted 		

			IF @Id_Transferencia IS NOT NULL
				BEGIN	
					--inser��o do lan�amento para a conta que est� transferindo 
					INSERT INTO [dbo].[Lancamentos](
														Id_Conta, 
														Id_Usuario, 
														Id_TipoLancamento, 
														Tipo_Operacao, 
														Vlr_Lanc, 
														Nom_Historico, 
														Dat_Lancamento, 
														Estorno 
												   )
											VALUES
												   (
														@Id_ContaDeb, 
														@Id_Usuario, 
														@TipoLancamento,
														'D', 
														@Vlr_Transferencia, 
														CONCAT(@Nom_Referencia,' Código Transferência: ', 
														@Id_Transferencia), 
														@Dat_Transferencia, 
														0)
					--Verifica se houve erro ao inserir dados em Lancamentos 	
					IF @@ERROR <> 0 OR @@ROWCOUNT <> 1
						BEGIN 
							RAISERROR('Erro na inclusão do lancamento de Débito', 16,1)
						END

					--Recuperando id_Transferencia que acabou de ser inserido e Executa a população da tabela [dbo].[LancamentosTransferencia]				SET @Id_LancamentoInserido = SCOPE_IDENTITY();
					SET @Id_LancamentoInserido = SCOPE_IDENTITY()
					
					EXEC  [dbo].[SP_RegistrarLancamentosTransferencia] @Id_Transferencia, @Id_LancamentoInserido
					--inseção do lancamento para a conta que est� recebendo a transferencia
					INSERT INTO [dbo].[Lancamentos](
													  Id_Conta, 
													  Id_Usuario, 
													  Id_TipoLancamento, 
													  Tipo_Operacao, 
													  Vlr_Lanc, 
													  Nom_Historico, 
													  Dat_Lancamento, 
													  Estorno 
												   )
											VALUES
												   (
													  @Id_ContaCre,
													  @Id_Usuario,  
													  @TipoLancamento,
													  'C',
													  @Vlr_Transferencia, 
													  CONCAT(@Nom_Referencia,' Código Transferência: ', 
													  @Id_Transferencia), 
													  @Dat_Transferencia, 
													  0
													)

					--Verifica se houve erro ao inserir dados em Lancamentos 	
					IF @@ERROR <> 0 OR @@ROWCOUNT <> 1
						BEGIN 
							RAISERROR('Erro na inclusão do lancamento de Crédito', 16,1)
						END
				
					--Recuperando id_Transferencia que acabou de ser inserido e Executa a população da tabela [dbo].[LancamentosTransferencia]
					SET @Id_LancamentoInserido = SCOPE_IDENTITY()
				
					EXEC  [dbo].[SP_RegistrarLancamentosTransferencia] @Id_Transferencia, @Id_LancamentoInserido
				END

			SET @Id_Transferencia = NULL 

			SELECT  @Id_Transferencia = Id,
					@Id_ContaCre = Id_Conta_Credito,
					@Id_ContaDeb = Id_Conta_Debito, 
					@Id_Usuario = Id_Usuario,
					@Vlr_Transferencia = Vlr_Trans,
					@Nom_Referencia = Nom_Referencia,
					@Dat_Transferencia = Dat_Trans   
				FROM deleted 

			--	Delete do Lan�amento de debito
			IF @Id_Transferencia IS NOT NULL
				BEGIN
					--insercao do lancamento ESTORNO para a conta que recebeu a transferencia
					INSERT INTO [dbo].[Lancamentos](
														Id_Conta, 
														Id_Usuario, 
														Id_TipoLancamento, 
														Tipo_Operacao, 
														Vlr_Lanc, 
														Nom_Historico, 
														Dat_Lancamento, 
														Estorno 
													)
											VALUES
													(
														@Id_ContaCre, 
														@Id_Usuario, 
														@TipoLancamento , 
														'D', 
														@Vlr_Transferencia, 
														CONCAT('Estorno enviado: ', @Nom_Referencia, ' Código Transferencia desfeita: ', 
														@Id_Transferencia), 
														@Dat_Transferencia, 
														1
													)
					
					IF @@ERROR <> 0 OR @@ROWCOUNT <> 1
						BEGIN 
							RAISERROR('Erro na inclusão do lancamento de estorno de Débito', 16,1)
						END

					--Recuperando id_Transferencia que acabou de ser inserido e Executa a população da tabela [dbo].[LancamentosTransferencia]
					SET @Id_LancamentoInserido = SCOPE_IDENTITY()
				
					EXEC  [dbo].[SP_RegistrarLancamentosTransferencia] @Id_Transferencia, @Id_LancamentoInserido
					--insercao do lancamento ESTORNO para a conta recebeu a transferencia
					INSERT INTO [dbo].[Lancamentos](
														Id_Conta, 
														Id_Usuario, 
														Id_TipoLancamento, 
														Tipo_Operacao, 
														Vlr_Lanc, 
														Nom_Historico, 
														Dat_Lancamento, 
														Estorno 
													)
											VALUES
													(
														@Id_ContaDeb,
														@Id_Usuario, 
														@TipoLancamento,
														'C',
														@Vlr_Transferencia, 
														CONCAT('Estorno recebido: ', @Nom_Referencia , ' Código Transferencia desfeita: ', 
														@Id_Transferencia), 
														@Dat_Transferencia,
														1
													)

					IF @@ERROR <> 0 OR @@ROWCOUNT <> 1
						BEGIN 
							RAISERROR('Erro na inclusão do lancamento de estorno de Crédito', 16,1)
						END
					--Recuperando id_Transferencia que acabou de ser inserido e Executa a população da tabela [dbo].[LancamentosTransferencia]
					SET @Id_LancamentoInserido = SCOPE_IDENTITY()
				
					EXEC  [dbo].[SP_RegistrarLancamentosTransferencia] @Id_Transferencia, @Id_LancamentoInserido
				END
	END
GO
