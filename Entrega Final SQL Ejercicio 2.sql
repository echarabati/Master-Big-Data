-- ENTREGA FINAL BIG DATA TECHNOLOGY AND ARCHITECTURE
-- Edmundo Charabati

/*
Pregunta numero 1
En la primera parte hacemos un delete dentro de una transaccion y se le da rollback, despues se hace un select a la tabla para ver como no se borro la informacion
En la segunda parte actualizamos la tabla de eventos y a todos los eventos les agregamos Edmond en el nombre
*/

-- Seleccionamos todos los datos de la tabla tblEvents y comprobamos que tiene bastantes datos
SELECT * FROM dbo.tblEvent
GO

-- Inicializamos la transaccion
BEGIN TRAN
	-- Borramos todos los datos de la tabla tblEvents
	DELETE FROM dbo.tblEvent

	-- Hacemos un select para confirmar que no hay datos en la tabla 
	SELECT * FROM dbo.tblEvent

	-- Se hace rollback a la transaccion para regresar al estado original
ROLLBACK TRAN
-- Volvemos a comprobar que la tabla tiene los datos que tenia antes de borrar
SELECT * FROM dbo.tblEvent
GO

-- Parte 2, se inicializa la transaccion
BEGIN TRAN
	-- Se actualizan los registros de tblEvent y se agrega EDMOND al nombre
	UPDATE dbo.tblEvent SET EventName = CONCAT(EventName, ' EDMOND') WHERE EventName NOT LIKE ('%EDMOND')
	-- Se hace un select para ver como queda
	SELECT * FROM dbo.tblEvent
COMMIT TRAN
-- Se vulve a hacer un select despues de cerrar la transaccion para verificar que los cambios si surtieron efecto
SELECT * FROM dbo.tblEvent
GO

/*
PREGUNTA 2

En la tabla de eventos la categoria y el pais solo aparecen con el ID de cada uno y el continente no aparece ya que este esta ligado a su vez al pais.
En el siguiente query obtendremos los eventos, detalles del evento, fecha, nombre del pais, nomnbre del continente y nombre de la categoria del evento
*/

SELECT Evento.EventID, Evento.EventName, Evento.EventDetails, Evento.EventDate, Pais.CountryName, Continente.ContinentName, Categoria.CategoryName
FROM dbo.tblEvent Evento
JOIN dbo.tblCountry Pais ON Evento.CountryID = Pais.CountryID
JOIN dbo.tblContinent Continente ON Pais.ContinentID = Continente.ContinentID
JOIN dbo.tblCategory Categoria ON Evento.CategoryID = Categoria.CategoryID
ORDER BY Evento.EventDate ASC
GO
/*
En este caso como continente hace join con pais y no con la tabla principal que es Evento podemos escribir el codigo de otra forma para que sea mas facil de leer
*/
WITH continente AS (
    SELECT Pais.CountryID, Pais.CountryName, Continente.ContinentName
    FROM dbo.tblCountry Pais
    JOIN dbo.tblContinent Continente ON Pais.ContinentID = Continente.ContinentID
)
SELECT Evento.EventID, Evento.EventName, Evento.EventDetails, Evento.EventDate, continente.CountryName, continente.ContinentName, Categoria.CategoryName
FROM dbo.tblEvent Evento
JOIN continente ON Evento.CountryID = continente.CountryID
JOIN dbo.tblCategory Categoria ON Evento.CategoryID = Categoria.CategoryID
ORDER BY Evento.EventDate ASC
GO
/*
PREGUNTA 3

función que devuelve el año del evento más antiguo para un continente determinado
*/

if exists (select * from sys.objects where name = 'fnAñoPrimerEvento')
	DROP FUNCTION fnAñoPrimerEvento
GO
CREATE FUNCTION fnAñoPrimerEvento(@continente nvarchar(50))
RETURNS int AS
BEGIN
	RETURN (
		SELECT TOP 1 YEAR(Evento.EventDate) 
		FROM dbo.tblEvent Evento
		JOIN dbo.tblCountry Pais ON Evento.CountryID = Pais.CountryID
		JOIN dbo.tblContinent Continente ON Pais.ContinentID = Continente.ContinentID
		WHERE Continente.ContinentName = @continente
		ORDER BY Evento.EventDate ASC
	)
END
GO

SELECT Continente.ContinentName, dbo.fnAñoPrimerEvento(Continente.ContinentName) AS 'PrimerEvento' FROM dbo.tblContinent Continente
GO

/*
PREGUNTA 4
stored procedure que añade un evento para un país determinado la tabla tblEvent, tambien comprueba que la categoria exista y en caso de que no la agrega
*/
if exists (select * from sys.objects where name = 'spAgregarEvento')
	DROP PROCEDURE spAgregarEvento
GO
CREATE PROCEDURE spAgregarEvento @Evento nvarchar(4000), @Descripcion nvarchar(max), @Fecha date, @Pais nvarchar(255), @Categoria nvarchar(255)
AS 
BEGIN
	BEGIN TRAN
	DECLARE
		@CategoryID			int,
		@CountryID			int

	-- Verifica si el pais existe y si no existe no despliega un error
	IF EXISTS (SELECT * FROM dbo.tblCountry WHERE CountryName = @Pais)
	BEGIN
		-- Verifica que la categoria exista y sino la inserta
		IF NOT EXISTS (SELECT * FROM dbo.tblCategory WHERE CategoryName = @Categoria)
		BEGIN
			INSERT dbo.tblCategory (CategoryName) VALUES (@Categoria)
			SELECT 'La Categoria ' + @Categoria +'. Se ha agregado con exito.'
		END
		-- Seleccionar datos faltantes para poder insertar los datos, hacer el insert y desplegar un mensaje de que se hizo y mostrar el resultado de la insercion.
		SELECT @CategoryID = CategoryID FROM dbo.tblCategory WHERE CategoryName = @Categoria
		SELECT @CountryID = CountryID FROM dbo.tblCountry WHERE CountryName = @Pais
		INSERT dbo.tblEvent (EventName, EventDetails, EventDate, CountryID, CategoryID) VALUES (@Evento, @Descripcion, @Fecha, @CountryID, @CategoryID)
		SELECT 'Se ha insertado el nuevo evento con exito'
		SELECT Evento.EventID, Evento.EventName, Evento.EventDetails, Evento.EventDate, Pais.CountryName, Continente.ContinentName, Categoria.CategoryName
		FROM dbo.tblEvent Evento
		JOIN dbo.tblCountry Pais ON Evento.CountryID = Pais.CountryID
		JOIN dbo.tblContinent Continente ON Pais.ContinentID = Continente.ContinentID
		JOIN dbo.tblCategory Categoria ON Evento.CategoryID = Categoria.CategoryID
		WHERE Evento.EventName = @Evento
	END
	ELSE
		SELECT 'El Pais indicado no existe por lo que no se puede insertar el evento. ' + @Pais

	COMMIT TRAN
END
GO

-- Esta llamada no debe de hacer nada ya que el pais 'España' no existe en la tabla, deberia ser 'Spain'
EXEC spAgregarEvento 'Evento de Prueba', 'Prueba para ver si funciona bien mi stored procedure', '2024-05-10', 'España', 'Categoria Nueva'
GO

-- Llamada con el pais correcto
EXEC spAgregarEvento 'Evento de Prueba', 'Prueba para ver si funciona bien mi stored procedure', '2024-05-10', 'Spain', 'Categoria Nueva'
GO