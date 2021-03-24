create database ExercicioFunc
go
use ExercicioFunc

/*
3) A partir das tabelas abaixo, faça:
Funcionário (Código, Nome, Salário)
Dependendente (Código_Funcionário, Nome_Dependente, Salário_Dependente)

a) Uma Function que Retorne uma tabela:
(Nome_Funcionário, Nome_Dependente, Salário_Funcionário, Salário_Dependente)

b) Uma Scalar Function que Retorne a soma dos Salários dos dependentes, mais a do funcionário.
*/

create table Funcionario(
codigo int,
nome varchar(MAX),
salario decimal(10,2)
primary key(codigo))

create table Dependente(
codigo int,
cod_funcionario int,
nome_dependente varchar(max),
salario_dependente decimal(10,2)
primary key(codigo),
foreign key(cod_funcionario) references Funcionario(codigo))

insert into Funcionario values
(1,'Nome1',1000.00),
(2,'Nome2',1500),
(3,'Nome3',2000),
(4,'Nome4',2500)
select * from Funcionario
insert into Dependente values
(1,1,'Dep1',500.00),
(2,2,'Dep2',1000.00),
(3,3,'Dep3',1500.00),
(4,4,'Dep4',500.00)
select * from Dependente

/*
a) Uma Function que Retorne uma tabela:
(Nome_Funcionário, Nome_Dependente, Salário_Funcionário, Salário_Dependente)
*/
CREATE FUNCTION fn_tabelaFuncDepen()
RETURNS @tabela TABLE(
nome_funcionario varchar(max),
nome_dependente varchar(max),
salario_funcionario decimal(10,2),
salario_dependente decimal(10,2)
)
AS
BEGIN
	insert into @tabela select f.nome,d.nome_dependente,f.salario,d.salario_dependente from Dependente d,Funcionario f where d.cod_funcionario = f.codigo
	RETURN 
END
select * from fn_tabelaFuncDepen()

/* b) Uma Scalar Function que Retorne a soma dos Salários dos dependentes, mais a do funcionário.*/
CREATE FUNCTION fn_tabelaSomaSalarios()
RETURNS decimal(20,2) 
AS
BEGIN
	declare @salFunc decimal(20,2),@salDepen decimal(20,2),@total decimal(20,2)
	set @salFunc = (select sum(salario) from Funcionario)
	set @salDepen = (select sum(salario_dependente) from Dependente)
	set @total = @salDepen + @salFunc
	return @total
END
select dbo.fn_tabelaSomaSalarios() as Soma

/*
4)A partir das tabelas abaixo, faça:
Cliente (CPF, nome, telefone, e-mail)
Produto (Código, nome, descrição, valor_unitário)
Venda (CPF_Cliente, Código_Produto, Quantidade, Data(Formato DATE))

a) Uma Function que Retorne uma tabela:
(Nome_Cliente, Nome_Produto, Quantidade, Valor_Total)

b) Uma Scalar Function que Retorne a soma dos produtos comprados na Última Compra
*/

create table Cliente(
cpf varchar(11),
nome varchar(max),
telefone varchar(20),
email varchar(50)
primary key(cpf))

create table Produto(
codigo int,
nome varchar(80),
descricao varchar(max),
valor_unitario decimal(10,2)
primary key(codigo))

create table Venda(
id int,
cpf_cliente varchar(11),
codigo_produto int,
quantidade int,
data_compra date
primary key(id),
foreign key(cpf_cliente) references Cliente(cpf),
foreign key(codigo_produto) references Produto(codigo))

insert into Cliente values
('1111','Nome1','1111','email1'),
('2222','Nome2','2222','email2'),
('3333','Nome3','3333','email3')

insert into Produto values
(1,'Prod1','Desc1',10.00),
(2,'Prod2','Desc2',20.00),
(3,'Prod3','Desc3',30.00),
(4,'Prod4','Desc4',40.00)

insert into Venda values
(1,'1111',1,3,GETDATE()),
(2,'1111',2,5,GETDATE()),
(3,'2222',2,2,GETDATE()),
(4,'2222',3,1,GETDATE()),
(5,'3333',3,2,GETDATE()),
(6,'3333',4,3,'10/10/2010')

-- a) Uma Function que Retorne uma tabela:
-- (Nome_Cliente, Nome_Produto, Quantidade, Valor_Total)
CREATE FUNCTION fn_tabelaVendas()
RETURNS @tabela TABLE(
nome_cliente varchar(max),
nome_produto varchar(max),
quantidade int,
valor_total decimal(10,2)
)
AS
BEGIN
	insert into @tabela select c.nome,p.nome,v.quantidade, (p.valor_unitario * v.quantidade) as valor_total from Cliente c, Produto p, Venda v where v.cpf_cliente = c.cpf and v.codigo_produto = p.codigo
	RETURN 
END
select * from fn_tabelaVendas()


/* b) Uma Scalar Function que Retorne a soma dos produtos comprados na Última Compra */

CREATE FUNCTION fn_valorCompras(@cpf varchar(4))
RETURNS decimal(10,2)
AS
BEGIN
	declare @valorCompra decimal(10,2)
	set @valorCompra = (select TOP(1) (p.valor_unitario * v.quantidade) as valor_total from Cliente c, Produto p, Venda v 
	where v.cpf_cliente = c.cpf and v.codigo_produto = p.codigo and c.cpf = @cpf Order by data_compra)
	return @valorCompra
END

select dbo.fn_valorCompras('3333') as valorComprars