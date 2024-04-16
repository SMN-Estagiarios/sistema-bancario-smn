CREATE DATABASE SistemaBancario
USE SistemaBancario
GO

CREATE TABLE Usuarios(
	Id INT IDENTITY PRIMARY KEY, 
	Nom_Usuario VARCHAR(50) NOT NULL 
); 

CREATE TABLE Contas (
	Id INT IDENTITY PRIMARY KEY,
	Vlr_SldInicial DECIMAL (15,2) NOT NULL, 
	Vlr_Credito DECIMAL (15,2) NOT NULL,
	Vlr_Debito DECIMAL (15,2) NOT NULL, 
	Dat_Saldo DATE NOT NULL,
	Dat_Abertura DATE NOT NULL,
	Dat_Encerramento DATE, 
	Ativo CHAR(1) NOT NULL,
	Lim_ChequeEspecial DECIMAL(15,2) NOT NULL

); 

CREATE TABLE Tarifas(
	Id TINYINT PRIMARY KEY IDENTITY,
	Nome VARCHAR(50) NOT NULL, 
	Valor DECIMAL(4,2),
	Taxa DECIMAL(5,4)
	);


CREATE TABLE Lancamentos(
	Id INT IDENTITY PRIMARY KEY, 
	Id_Cta INT NOT NULL,
	Id_Usuario INT NOT NULL,
	Id_Tarifa TINYINT NOT NULL,
	Tipo_Lanc CHAR(1)NOT NULL,
	Vlr_Lanc Decimal (15,2) NOT NULL,
	Nom_Historico VARCHAR(500) NOT NULL,
	Dat_Lancamento DATETIME NOT NULL
	CONSTRAINT FK_Conta_Lancamento FOREIGN KEY (Id_Cta) references Contas(Id),
	CONSTRAINT FK_Usuario_Lancamento FOREIGN KEY (Id_Usuario) references Usuarios(Id),
	CONSTRAINT CHK_Tipo_Lanc_C_D CHECK(Tipo_Lanc LIKE '[c,C]' OR Tipo_Lanc LIKE '[D,d]'),
	CONSTRAINT FK_Tarifa_Lancamentos FOREIGN KEY (Id_Tarifa) references Tarifas(Id)
);

CREATE TABLE Transferencias(
	Id INT PRIMARY KEY IDENTITY, 
	Id_Usuario INT NOT NULL,
	Id_CtaCre INT NOT NULL, 
	Id_CtaDeb INT NOT NULL, 
	Vlr_TRans DECIMAL (15,2) NOT NULL,
	Nom_Referencia VARCHAR (200) NOT NULL,
	Dat_Trans DATETIME NOT NULL,
	CONSTRAINT FK_Conta_Credito FOREIGN KEY (Id_CtaCre) REFERENCES Contas(Id),
	CONSTRAINT FK_Conta_Debito FOREIGN KEY (Id_CtaDeb) REFERENCES Contas(Id),
	CONSTRAINT FK_UsuarioTransferencia  FOREIGN KEY (Id_Usuario ) REFERENCES Usuarios(Id)

); 
