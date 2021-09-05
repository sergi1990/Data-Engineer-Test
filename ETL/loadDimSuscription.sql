SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROC [dwhPlatzi].[uspTL_DimSuscription] AS 

/*---------------------------------------------------------------------------------------------------------------------
Descripcion: Procedimiento que se encarga de cargar a la tabla [dwhPlatzi].[dimSuscriptions] 
Author: Edison Yepes S - 2021-09-04

Modificaciones
Author			Date		Coments
Edison Yepes S.    04/09/2021  Creación del documento
-----------------------------------------------------------------------------------------------------------------------*/

-----------------------------------------------------------------------
--Se insertan los registros nuevos
-----------------------------------------------------------------------

INSERT INTO   [dwhPlatzi].[dimSuscriptions]
(   [idSuscription] ,
	[codSuscripcion] ,
	[realStartDate] ,
	[status] ,
	[loadDate]
SELECT sec.sk+ROW_NUMBER() OVER(ORDER BY (SELECT NULL)) ,
	sus.codSuscripcion,
    sus.fechaInicio,
    sus.estadoSuscripcion,
    getdate()
FROM [dbPlatzi].[tblEstudianteSuscripcion] sus
LEFT JOIN [dbPlatzi].[dimSuscriptions] dim 
ON dim.codSuscripcion = sus.codSuscripcion
cross join (select ISNULL(MAX(idSuscription),0) sk from [dwhPlatzi].[dimSuscriptions] ) sec
where dim.codSuscripcion is null 

-----------------------------------------------------------------------
--Se actualizan los registros modificados
-----------------------------------------------------------------------

UPDATE [dwhPlatzi].[dimSuscriptions] 
SET 
    realStartDate= sus.fechaInicio,
    status=sus.estadoSuscripcion,
	loadDate = getdate()
FROM [dbPlatzi].[tblEstudianteSuscripcion] sus
INNER JOIN [dbPlatzi].[dimSuscriptions] dim 
ON dim.codSuscripcion = sus.codSuscripcion




