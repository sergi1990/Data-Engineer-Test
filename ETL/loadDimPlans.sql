SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROC [dwhPlatzi].[uspTL_DimPlans] AS 

/*---------------------------------------------------------------------------------------------------------------------
Descripcion: Procedimiento que se encarga de cargar a la tabla [dwhPlatzi].[dimPlans] 
Author: Edison Yepes S - 2021-09-04

Modificaciones
Author			Date		Coments
Edison Yepes S.    04/09/2021  Creación del documento
-----------------------------------------------------------------------------------------------------------------------*/

-----------------------------------------------------------------------
--Se insertan los registros nuevos
-----------------------------------------------------------------------

INSERT INTO   [dwhPlatzi].[dimPlans]
(   [idPlan] ,
	[codPlan] ,
	[descPlan] ,
	[pricing] ,
	[anualPricing] ,
	[status] ,
	[loadDate]
SELECT sec.sk+ROW_NUMBER() OVER(ORDER BY (SELECT NULL)) ,
	plan.codPlan,
    plan.descPlan,
    plan.precioPorMes,
    plan.precioAnual,
    plan.estadoPlan,
    getdate()
FROM [dbPlatzi].[tblPlanes] plan
LEFT JOIN [dbPlatzi].[dimPlans] dim 
ON dim.codPlan = plan.codPlan
cross join (select ISNULL(MAX(idPlan),0) sk from [dwhPlatzi].[dimPlans] ) sec
where dim.codPlan is null 

-----------------------------------------------------------------------
--Se actualizan los registros modificados
-----------------------------------------------------------------------

UPDATE [dwhPlatzi].[dimPlans] 
SET 
    descPlan= plan.descPlan,
    pricing=plan.precioPorMes,
	anualPricing=plan.precioAnual,
    status=plan.estadoPlan,
	loadDate = getdate()
FROM [dbPlatzi].[tblPlanes] plan
INNER JOIN [dbPlatzi].[dimPlans] dim 
ON dim.codPlan = plan.codPlan




