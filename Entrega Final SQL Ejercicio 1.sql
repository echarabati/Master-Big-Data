/*
Entrega final Edmundo Charabati

PREGUNTA 1
El siguiente script crea una base de datos llamada Edmond en la que simularemos un esquema de ventas de una comercializadora de vinos muy sencillo. 
Se crean 5 tablas: Cliente, Articulo, Sucursal, Venta y VentaD
Las tablas sucursal y Articulo se hicieron para ejemplificar mejor como quedaria normalizada la base de datos.

En la tabla Cliente se almacenan los datos de todos los clientes que se han dado de alta y cada uno tiene un ID unico.
En la tabla Venta se registran todos los tickets de ventas del dia, se guarda la fecha, el cliente y la sucursal donde se hizo la venta.
En la tabla VentaD se resgistra el detalle de articulos de cada ticket.

La relacion entre la tabla Cliente y Venta es uno a muchos ya que pueden haber muchas ventas a un mismo cliente. En cambio, una venta solo tiene un unico cliente asignado
La relacion entre la tabla Venta y VentaD es uno a muchos ya que un ticket puede tener muchos articulos pero un detalle solo puede pertenecer a un unico encabezado
La relacion entre la tabla Venta y Sucursal es uno a muchos ya que una venta tiene una unica sucursal, pero una sucursal puede tener muchas ventas
La relacion entre la tabla VentaD y Articulo es N a M ya que una venta puede tener N articulos y un articulo puede aparecer en M ventas

PREGUNTA 2
La Tabla Venta tiene 2 foreign keyes con las tablas de Cliente y Sucursal para garantizar integridad referencial, no podemos borrar nada de estas tablas 
si existen datos en la tabla de ventas. 
Ademas el campo Sucursal tiene un ON UPDATE CASCADE por lo que si se cambia la tabla de sucursal, cambia todos los registros en Venta

La tabla de VentaD tiene 2 foreign keyes con las tablas de Venta y Articulo. En el caso de forreign key de Venta ademas especifica on DELETE CASCADE debido a que 
al borrar una venta se deben de eliminar tambien todos los renglones de VentaD ya que no tendria sentido tener un detalle de venta sin su encabezado.

Para ambos casos se presenta un ejemplo mas adelante.
*/

-- Crea la base de datos, si ya existe no hace nada
if not exists(select * from sys.databases where name = 'Edmond')
	CREATE DATABASE Edmond;
GO
USE Edmond;
GO

-- Verifica que no existan las tablas, en caso de que si las borra
if exists (select * from sysobjects where name = 'VentaD')
	DROP TABLE VentaD;
if exists (select * from sysobjects where name = 'Venta')
	DROP TABLE Venta;
if exists (select * from sysobjects where name = 'Cliente')
	DROP TABLE Cliente;
if exists (select * from sysobjects where name = 'Articulo')
	DROP TABLE Articulo;
if exists (select * from sysobjects where name = 'Sucursal')
	DROP TABLE Sucursal;
GO

-- Creacion de tablas
CREATE TABLE Cliente
	(
		ClienteID			int				NOT NULL		PRIMARY KEY IDENTITY(1,1),
		Nombre				varchar(50)		NOT NULL,
		ApellidoPaterno		varchar(50)		NULL,
		ApellidoMaterno		varchar(50)		NULL,
		Telefono			varchar(15)		NULL,
		EMail				varchar(50)		NULL,
		Direccion			varchar(50)		NULL,
		Direccion2			varchar(50)		NULL,
		Poblacion			varchar(50)		NULL,
		Provincia			varchar(50)		NULL,
		Pais				varchar(50)		NULL
	);
GO

CREATE TABLE Articulo 
	(
		Articulo			varchar(20)		NOT NULL	PRIMARY KEY,
		Descripcion			varchar(100)	NULL,
		UnidadVenta			varchar(10)		NULL
	);
GO

CREATE TABLE Sucursal
	(
		Sucursal			varchar(50)		PRIMARY KEY,
		Direccion			Varchar(100)	NULL,
		NumeroExt			int				NULL,
		Barrio				varchar(50)		NULL,
		CodigoPostal		varchar(5)		NULL,
		Poblacion			varchar(50)		NULL,
		Pais				varchar(50)		NULL,
	);
GO

CREATE TABLE Venta
	(	
		ID					int				NOT NULL		PRIMARY KEY IDENTITY(1,1),
		Fecha				date			NOT NULL		DEFAULT (getdate()),
		ClienteID			int				NOT NULL,
		Sucursal			varchar(50)		NOT NULL,

		CONSTRAINT fkVentaCte FOREIGN KEY (ClienteID) REFERENCES Cliente(ClienteID),
		CONSTRAINT fkVentaSuc FOREIGN KEY (Sucursal) REFERENCES Sucursal(Sucursal) ON UPDATE CASCADE
	);
GO
		
CREATE TABLE VentaD
	(	
		DetalleID				int			NOT NULL	PRIMARY KEY IDENTITY(1,1),
		VentaID					int			NOT NULL,
		Articulo				varchar(20)	NOT NULL,	
		Cantidad				float		NOT NULL	DEFAULT 0.0,
		Precio					float		NOT NULL	DEFAULT 0.0,

		CONSTRAINT fkVentaDID FOREIGN KEY (VentaID) REFERENCES Venta(ID) ON DELETE CASCADE,
		CONSTRAINT fkVentaDArt FOREIGN KEY (Articulo) REFERENCES Articulo(Articulo)
	);
GO

-- Llenar registros de las tablas de sucursal, articulo y cliente
INSERT INTO Sucursal VALUES ('Mercat de la Boqueria', 'La Rambla', 91, 'Ciutat Vella', '08001', 'Barcelona', 'España');
INSERT INTO Sucursal VALUES ('Mercat de Sant Antoni', 'Carrer del Comte d''Urgell', 1, 'L''Eixample', '08011', 'Barcelona', 'España');
INSERT INTO Sucursal VALUES ('Mercat de Sant Andreu', 'Plaça del Mercadal', 41, 'Sant Andreu', '08030', 'Barcelona', 'España');
GO

INSERT INTO Articulo (Articulo, Descripcion, UnidadVenta) VALUES ('V0001', 'Vino tinto Rioja', 'Pieza');
INSERT INTO Articulo (Articulo, Descripcion, UnidadVenta) VALUES ('V0002', 'Vino blanco Albariño', 'Caja');
INSERT INTO Articulo (Articulo, Descripcion, UnidadVenta) VALUES ('V0003', 'Vino tinto Ribera del Duero', 'Pieza');
INSERT INTO Articulo (Articulo, Descripcion, UnidadVenta) VALUES ('V0004', 'Vino tinto Priorat', 'Caja');
INSERT INTO Articulo (Articulo, Descripcion, UnidadVenta) VALUES ('V0005', 'Vino tinto Toro', 'Pieza');
GO

INSERT INTO Cliente (Nombre, ApellidoPaterno, ApellidoMaterno, Telefono, EMail, Direccion, Direccion2, Poblacion, Provincia, Pais)
VALUES 
('María', 'García', 'Martínez', '123456789', 'maria.garcia@example.com', 'Calle Mayor', 'Apartamento 1', 'Barcelona', 'Barcelona', 'España'),
('Carlos', 'Pérez', NULL, '987654321', 'carlos.perez@example.com', 'Avenida Diagonal', 'Piso 2', 'Barcelona', 'Barcelona', 'España'),
('Laura', 'Sánchez', 'López', '654123789', 'laura.sanchez@example.com', 'Carrer Gran', NULL, 'Barcelona', 'Barcelona', 'España'),
('Pablo', 'Martínez', NULL, '987123654', 'pablo.martinez@example.com', 'Plaça Espanya', 'Piso 3', 'Barcelona', 'Barcelona', 'España'),
('Ana', 'González', 'García', '321654987', 'ana.gonzalez@example.com', 'Carrer Sant Pere', 'Piso 4', 'Barcelona', 'Barcelona', 'España'),
('José', 'Fernández', 'Rodríguez', '456789123', 'jose.fernandez@example.com', 'Carrer Major', NULL, 'Barcelona', 'Barcelona', 'España'),
('Sara', 'Ruiz', NULL, '789456123', 'sara.ruiz@example.com', 'Avinguda Meridiana', 'Piso 5', 'Barcelona', 'Barcelona', 'España'),
('Manuel', 'Jiménez', 'Sánchez', '987789123', 'manuel.jimenez@example.com', 'Carrer Rambla', 'Piso 6', 'Barcelona', 'Barcelona', 'España'),
('Elena', NULL, NULL, '123789456', 'elena@example.com', 'Passeig de Gràcia', 'Piso 7', 'Barcelona', 'Barcelona', 'España'),
('Javier', 'Martín', 'Pérez', '654987123', 'javier.martin@example.com', 'Carrer Diputació', 'Piso 8', 'Barcelona', 'Barcelona', 'España'),
('Carmen', 'López', NULL, '789123654', 'carmen.lopez@example.com', 'Carrer Sardenya', 'Piso 9', 'Barcelona', 'Barcelona', 'España'),
('David', 'Gómez', 'Fernández', '321789654', 'david.gomez@example.com', 'Carrer Balmes', 'Piso 10', 'Barcelona', 'Barcelona', 'España'),
('Isabel', 'Pérez', 'González', '987123789', 'isabel.perez@example.com', 'Carrer Consell de Cent', 'Piso 11', 'Barcelona', 'Barcelona', 'España'),
('Francisco', 'Fernández', 'Ruiz', '654789123', 'francisco.fernandez@example.com', 'Carrer Aragó', 'Piso 12', 'Barcelona', 'Barcelona', 'España'),
('Lucía', 'Martínez', 'Sánchez', '789321654', 'lucia.martinez@example.com', 'Carrer Rosselló', 'Piso 13', 'Barcelona', 'Barcelona', 'España');
GO

-- Insertar datos de ventas
INSERT INTO Venta (Fecha, ClienteID, Sucursal) VALUES ('2022-04-28', 12, 'Mercat de la Boqueria')
INSERT INTO VentaD (VentaID, Articulo, Cantidad, Precio) VALUES (1, 'V0005', 4, 14.33)

INSERT INTO Venta (Fecha, ClienteID, Sucursal) VALUES ('2022-07-16', 6, 'Mercat de Sant Andreu')
INSERT INTO VentaD (VentaID, Articulo, Cantidad, Precio) VALUES (2, 'V0001', 4, 8.8)
INSERT INTO VentaD (VentaID, Articulo, Cantidad, Precio) VALUES (2, 'V0004', 12, 37.03)

INSERT INTO Venta (Fecha, ClienteID, Sucursal) VALUES ('2022-10-21', 14, 'Mercat de Sant Andreu')
INSERT INTO VentaD (VentaID, Articulo, Cantidad, Precio) VALUES (3, 'V0002', 24, 132.49)
INSERT INTO VentaD (VentaID, Articulo, Cantidad, Precio) VALUES (3, 'V0002', 24, 46.66)

INSERT INTO Venta (Fecha, ClienteID, Sucursal) VALUES ('2022-01-10', 2, 'Mercat de Sant Antoni')
INSERT INTO VentaD (VentaID, Articulo, Cantidad, Precio) VALUES (4, 'V0005', 2, 14.89)
INSERT INTO VentaD (VentaID, Articulo, Cantidad, Precio) VALUES (4, 'V0005', 5, 17.47)
INSERT INTO VentaD (VentaID, Articulo, Cantidad, Precio) VALUES (4, 'V0005', 3, 22.15)

INSERT INTO Venta (Fecha, ClienteID, Sucursal) VALUES ('2022-06-12', 10, 'Mercat de Sant Andreu')
INSERT INTO VentaD (VentaID, Articulo, Cantidad, Precio) VALUES (5, 'V0002', 48, 50.43)
INSERT INTO VentaD (VentaID, Articulo, Cantidad, Precio) VALUES (5, 'V0003', 5, 23.6)
INSERT INTO VentaD (VentaID, Articulo, Cantidad, Precio) VALUES (5, 'V0003', 2, 10.08)
INSERT INTO VentaD (VentaID, Articulo, Cantidad, Precio) VALUES (5, 'V0005', 3, 9.25)

INSERT INTO Venta (Fecha, ClienteID, Sucursal) VALUES ('2022-01-11', 5, 'Mercat de la Boqueria')
INSERT INTO VentaD (VentaID, Articulo, Cantidad, Precio) VALUES (6, 'V0005', 2, 23.05)
INSERT INTO VentaD (VentaID, Articulo, Cantidad, Precio) VALUES (6, 'V0005', 3, 9.05)
INSERT INTO VentaD (VentaID, Articulo, Cantidad, Precio) VALUES (6, 'V0004', 60, 57.12)
INSERT INTO VentaD (VentaID, Articulo, Cantidad, Precio) VALUES (6, 'V0001', 4, 11.68)
INSERT INTO VentaD (VentaID, Articulo, Cantidad, Precio) VALUES (6, 'V0001', 1, 19.11)

INSERT INTO Venta (Fecha, ClienteID, Sucursal) VALUES ('2022-11-19', 12, 'Mercat de la Boqueria')
INSERT INTO VentaD (VentaID, Articulo, Cantidad, Precio) VALUES (7, 'V0003', 4, 14.94)
INSERT INTO VentaD (VentaID, Articulo, Cantidad, Precio) VALUES (7, 'V0001', 3, 18.04)
INSERT INTO VentaD (VentaID, Articulo, Cantidad, Precio) VALUES (7, 'V0005', 4, 21.15)
INSERT INTO VentaD (VentaID, Articulo, Cantidad, Precio) VALUES (7, 'V0004', 24, 142.56)

INSERT INTO Venta (Fecha, ClienteID, Sucursal) VALUES ('2022-03-01', 2, 'Mercat de la Boqueria')
INSERT INTO VentaD (VentaID, Articulo, Cantidad, Precio) VALUES (8, 'V0005', 2, 8.34)
INSERT INTO VentaD (VentaID, Articulo, Cantidad, Precio) VALUES (8, 'V0005', 3, 21.99)

INSERT INTO Venta (Fecha, ClienteID, Sucursal) VALUES ('2022-01-31', 4, 'Mercat de Sant Antoni')
INSERT INTO VentaD (VentaID, Articulo, Cantidad, Precio) VALUES (9, 'V0005', 4, 18.41)
INSERT INTO VentaD (VentaID, Articulo, Cantidad, Precio) VALUES (9, 'V0005', 1, 23.1)
INSERT INTO VentaD (VentaID, Articulo, Cantidad, Precio) VALUES (9, 'V0004', 24, 97.75)
INSERT INTO VentaD (VentaID, Articulo, Cantidad, Precio) VALUES (9, 'V0004', 60, 84.01)

INSERT INTO Venta (Fecha, ClienteID, Sucursal) VALUES ('2022-02-06', 9, 'Mercat de Sant Antoni')
INSERT INTO VentaD (VentaID, Articulo, Cantidad, Precio) VALUES (10, 'V0001', 3, 14.37)
INSERT INTO VentaD (VentaID, Articulo, Cantidad, Precio) VALUES (10, 'V0004', 36, 138.67)
INSERT INTO VentaD (VentaID, Articulo, Cantidad, Precio) VALUES (10, 'V0005', 3, 16.27)
INSERT INTO VentaD (VentaID, Articulo, Cantidad, Precio) VALUES (10, 'V0004', 60, 149.24)

INSERT INTO Venta (Fecha, ClienteID, Sucursal) VALUES ('2022-06-19', 11, 'Mercat de Sant Andreu')
INSERT INTO VentaD (VentaID, Articulo, Cantidad, Precio) VALUES (11, 'V0001', 4, 17.54)
INSERT INTO VentaD (VentaID, Articulo, Cantidad, Precio) VALUES (11, 'V0005', 2, 13.27)

INSERT INTO Venta (Fecha, ClienteID, Sucursal) VALUES ('2022-05-30', 4, 'Mercat de Sant Antoni')
INSERT INTO VentaD (VentaID, Articulo, Cantidad, Precio) VALUES (12, 'V0001', 1, 18.43)
INSERT INTO VentaD (VentaID, Articulo, Cantidad, Precio) VALUES (12, 'V0004', 12, 64.31)

INSERT INTO Venta (Fecha, ClienteID, Sucursal) VALUES ('2022-03-29', 6, 'Mercat de la Boqueria')
INSERT INTO VentaD (VentaID, Articulo, Cantidad, Precio) VALUES (13, 'V0003', 4, 18.72)
INSERT INTO VentaD (VentaID, Articulo, Cantidad, Precio) VALUES (13, 'V0004', 36, 89.16)

INSERT INTO Venta (Fecha, ClienteID, Sucursal) VALUES ('2022-08-30', 12, 'Mercat de Sant Antoni')
INSERT INTO VentaD (VentaID, Articulo, Cantidad, Precio) VALUES (14, 'V0001', 4, 18.83)
INSERT INTO VentaD (VentaID, Articulo, Cantidad, Precio) VALUES (14, 'V0001', 4, 15.42)
INSERT INTO VentaD (VentaID, Articulo, Cantidad, Precio) VALUES (14, 'V0005', 1, 17.21)

INSERT INTO Venta (Fecha, ClienteID, Sucursal) VALUES ('2022-02-14', 4, 'Mercat de Sant Andreu')
INSERT INTO VentaD (VentaID, Articulo, Cantidad, Precio) VALUES (15, 'V0003', 1, 14.64)
INSERT INTO VentaD (VentaID, Articulo, Cantidad, Precio) VALUES (15, 'V0004', 24, 130.33)
INSERT INTO VentaD (VentaID, Articulo, Cantidad, Precio) VALUES (15, 'V0005', 3, 8.73)
INSERT INTO VentaD (VentaID, Articulo, Cantidad, Precio) VALUES (15, 'V0003', 4, 19.05)
GO


--PREGUNTA 3: EJEMPLOS DE FUNCIONAMIENTO DE LOS FOREIGN KEYES
/*
1. ON UPDATE CASCADE
El primer select trae las ventas por sucursal.
Mas adelante se hace un update al nombre de la sucursal del Mercat de la Boqueria y se le agrega un numero ya que abrio otra sucursal ahi
El segundo select muestra como todos los registros de Venta con la sucursal de Mercat de la Boqueria cambiaron en automatico
*/
SELECT 'Ejemplo de Update en Cascada antes de Actualizar' AS ' '
SELECT * FROM Venta
UPDATE Sucursal SET Sucursal = 'Mercat de la Boqueria 1' WHERE Sucursal = 'Mercat de la Boqueria'
SELECT 'Ejemplo de Update en Cascada despues de Actualizar' AS ' '
SELECT * From Venta
GO
/*
2. ON DELETE CASCADE
El primer select muestra el encabezado y detalle de la venta numero 7
Despues se borra el encabezado y se ejecuta un segundo select donde se puede ver que el detalle correspondiente tampoco aparece
*/

SELECT 'Ejemplo de Delete en Cascada Antes de borrar' AS ' '
SELECT * FROM Venta V JOIN VentaD D ON V.ID = D.VentaID WHERE V.ID = 7 
DELETE FROM Venta WHERE ID = 7
SELECT 'Ejemplo de Delete en Cascada Despues de borrar' AS ' '
SELECT * FROM VentaD WHERE VentaID = 7
GO

-- PREGUNTA 4: Diferencia entre INNER JOIN y OUTER JOIN
/*
Si quisieramos sacar las ventas por cliente tenemos que juntar las tablas de Venta, VentaD y Cliente.
Venta y VentaD se unen con un inner join por que no hay detalle sin encabezado y no hay encabezado sin detalle.
Si unimos la tabla Cliente con un inner join solo obtendremos las ventas de los clientes que han comprado alguna vez
Si unimos la tabla Cliente con un outer join obtendremos datos de todos los clientes aunque no hayan comprado.
*/
SELECT 'Ejemplo de Inner Join' AS ' '
SELECT c.ClienteID, CONCAT(c.Nombre, ' ', c.ApellidoPaterno, ' ' , c.ApellidoMaterno) As NombreCliente, SUM(ISNULL(d.Cantidad*d.Precio,0)) As ImporteVenta
  FROM Venta v
  JOIN VentaD d ON v.ID = d.VentaID
  JOIN Cliente c ON v.ClienteID = c.ClienteID
GROUP BY c.ClienteID, c.Nombre,c.ApellidoPaterno, c.ApellidoMaterno

SELECT 'Ejemplo de Outer Join' AS ' '
SELECT c.ClienteID, CONCAT(c.Nombre, ' ', c.ApellidoPaterno, ' ' , c.ApellidoMaterno) As NombreCliente, SUM(ISNULL(d.Cantidad*d.Precio,0)) As ImporteVenta
  FROM Venta v
  JOIN VentaD d ON v.ID = d.VentaID
  RIGHT JOIN Cliente c ON v.ClienteID = c.ClienteID
GROUP BY c.ClienteID, c.Nombre,c.ApellidoPaterno, c.ApellidoMaterno
GO

-- PREGUNTA 5: Ejemplo de funciones de agregacion con clausulas GROUP BY Y HAVING
-- Con este query vamos a obtener el importe total por ticket de las ventas en el mercat de sant antoni unicamente
SELECT 'Ejemplo de Clausulas Group by y Having' AS ' '
SELECT v.ID, v.Sucursal, SUM(d.Cantidad * d.Precio) as Importe
  FROM Venta v
  JOIN Cliente c ON v.ClienteID = c.ClienteID
  JOIN VentaD d ON v.ID = d.VentaID
 GROUP BY v.ID, v.Sucursal
 HAVING v.Sucursal = 'Mercat de Sant Antoni'
 GO