SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROC [dwhPlatzi].[uspTL_DimStudents] AS 

/*---------------------------------------------------------------------------------------------------------------------
Descripcion: Procedimiento que se encarga de cargar a la tabla [dwhPlatzi].[dimStudents] 
Author: Edison Yepes S - 2021-09-04

Modificaciones
Author			Date		Coments
Edison Yepes S.    04/09/2021  Creación del documento
-----------------------------------------------------------------------------------------------------------------------*/

-----------------------------------------------------------------------
--Se insertan los registros nuevos
-----------------------------------------------------------------------

INSERT INTO   [dwhPlatzi].[dimStudents]
(   [idStudent] ,
	[codEstudiante] ,
	[document] ,
	[documentType] ,
	[name] ,
	[lastName] ,
	[email] ,
	[phone] ,
	[nationality],
	[loadDate]
SELECT sec.sk+ROW_NUMBER() OVER(ORDER BY (SELECT NULL)) ,
	est.codEstudiante,
    est.numeroIdentificacion,
    est.tipoIdentificacion,
    est.nombre,
    est.primerApellido||" "est.segundoApellido,
    estcon.correoElectronico,
	estcon.numeroTelefono,
	estcon.nacionalidad,
    getdate()
FROM [dbPlatzi].[tblEstudiantes] est
LEFT JOIN [dbPlatzi].[tblEstudiantesContacto] estcon 
ON est.codEstudiante = estcon.codEstudiante
LEFT JOIN [dbPlatzi].[dimStudents] fact 
ON est.codEstudiante = estcon.codEstudiante
cross join (select ISNULL(MAX(idStudent),0) sk from [dwhPlatzi].[dimStudents] ) sec
where fact.codEstudiante is null 

-----------------------------------------------------------------------
--Se actualizan los registros modificados
-----------------------------------------------------------------------

UPDATE [dwhPlatzi].[dimStudents] 
SET 
    document= est.numeroIdentificacion,
    documentType=est.tipoIdentificacion,
    name=est.nombre,
    lastName=est.primerApellido||" "est.segundoApellido,
    email=estcon.correoElectronico,
    phone=estcon.numeroTelefono ,
	nationality=estcon.nacionalidad ,
	loadDate = getdate()
FROM [dbPlatzi].[tblEstudiantes] est
LEFT JOIN [dbPlatzi].[tblEstudiantesContacto] estcon 
ON est.codEstudiante = estcon.codEstudiante
INNER JOIN [dbPlatzi].[dimStudents] fact 
ON est.codEstudiante = estcon.codEstudiante


