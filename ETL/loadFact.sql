SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROC [dwhPlatzi].[uspTL_factSuscription] AS 

/*---------------------------------------------------------------------------------------------------------------------
Descripcion: Procedimiento que se encarga de cargar a la tabla [dwhPlatzi].[factSuscription] 
Author: Edison Yepes S - 2021-09-04

Modificaciones
Author			Date		Coments
Edison Yepes S.    04/09/2021  Creación del documento
-----------------------------------------------------------------------------------------------------------------------*/

-----------------------------------------------------------------------
--genera la consulta
-----------------------------------------------------------------------
IF OBJECT_ID('tempdb..#TmpBase') IS NOT NULL
BEGIN
    DROP TABLE #TmpBase
END

select distinct 
       tbles.codSuscripcion as codSuscripcion,
	   tbles.codPlan as codPlan
	   est.codEstudiante as codEstudiante,
	   COUNT(asis.codAsistencia) as cantClasesRealizadas,
	   COUNT DISTINCT(plan.codClase) as cantTotalClases,
	   COUNT(CASE WHEN codEvento = 'PAUSE' then 1 END) cantPauses,
	   COUNT(CASE WHEN codEvento = 'COURTESIES' then 1 END) cantCourtesies,
	   SUM(valorPagado) as valorPagado
into #TmpBase
from [dbPlatzi].[tblEstudianteSuscripcion] tbles
left join [dbPlatzi].[tblEstudiantes]  est 
on tbles.codEstudiante = est.codEstudiante
left join [dbPlatzi].[tblAsistencias]  asis 
on asis.codEstudiante = est.codEstudiante
left join [dbPlatzi].[tblPlanesClases]  plan 
on plan.codRegistro = asis.codRegistro
left join [dbPlatzi].[tblPagos]  pag 
on pag.codSuscripcion = tbles.codSuscripcion
left join [dbPlatzi].[tblEstudianteSuscripcionHistorial]  estsh 
on estsh.codSuscripcion = tbles.codSuscripcion
and estsh.codEvento IN ('PAUSE', 'COURTESIES')
GROUP BY tbles.codSuscripcion,
tbles.codPlan,
est.codEstudiante


-----------------------------------------------------------------------
--realiza cruce para identificar id e inserta los registros nuevos
-----------------------------------------------------------------------
insert into  [dwhPlatzi].[factSuscription] 
(
	idRow,
	idSuscription,
	idStudent,
	idPlan,
	qtyCourses,
	qtyPauses,
	qtyCourtesies,
	valPaid
)
select sec.sk+ROW_NUMBER() OVER(ORDER BY (SELECT NULL)),
       coalesce(sus.idSuscription, -1) idSuscription,
       coalesce(est.idStudent, -1) idStudent,
       coalesce(plan.idPlan, -1) idPlan,
       tmp.cantClasesRealizadas, 
       tmp.cantTotalClases, 
       tmp.cantPauses,
       tmp.cantCourtesies
from #TmpBase tmp
left join [dwhPlatzi].[factSuscription] fact
on tmp.codSuscripcion = fact.codSuscripcion
and tmp.codPlan = fact.codPlan
and tmp.codEstudiante = fact.codEstudiante
left join [dwhPlatzi].[dimSuscription] sus
on sus.codSuscripcion = fact.codSuscripcion
left join [dwhPlatzi].[dimStudent] est
on est.codEstudiante = fact.codEstudiante
left join [dwhPlatzi].[dimPlans] plan
on plan.codPlan = fact.codPlan
cross join (select ISNULL(MAX(idRow),0) sk from [dwhPlatzi].[factSuscription] ) sec
where fact.codSuscripcion is null 


-----------------------------------------------------------------------
--Se actualizan los registros modificados
-----------------------------------------------------------------------

update fact
set  cantClasesRealizadas = tmp.cantClasesRealizadas,
     cantTotalClases = tmp.cantTotalClases,
     montoIntereses =  tmp.montoIntereses,
     cantCourtesies = tmp.cantCourtesies
from [dwhPlatzi].[factSuscription] fact
inner join #TmpBase tmp
on  fact.idSuscription = tmp.idSuscription 
and fact.idStudent = tmp.idStudent 
and fact.idPlan = tmp.idPlan 

