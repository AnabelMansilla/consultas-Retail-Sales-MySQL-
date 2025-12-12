--Creación de la base de datos

CREATE DATABASE ventas;
USE ventas;

--Se procede a importar la base de datos en formato CSV

--Se eliminan las columnas que son innecesarias para el análisis

ALTER TABLE retail_sales DROP COLUMN `Row ID`; 

ALTER TABLE retail_sales 
DROP COLUMN `Ship mode` ,
DROP COLUMN `Ship Date` ,
DROP COLUMN `Postal Code`; 

--Visualización de la base de datos final

SELECT * from retail_sales;

-- KPIs año 2017 - Resumen

SELECT
CONCAT('$',@ventas) AS `Total de ventas`,
CONCAT('$',@ganancias) AS `Ganancias`,
CONCAT(round((@ganancias/@ventas)*100,2),'%') AS `Margen de ganancia`,
@tickets as `Total de ordenes`,
CONCAT('$',ROUND((@ventas/@tickets),2)) AS `Ticket promedio`,
ROUND((@cantidad/@tickets),2) AS PPT
FROM(
SELECT
@ventas:=sum(sales),
@ganancias:=sum(profit),
@tickets:= count(distinct `Order ID`),
@cantidad:=sum(Quantity)
FROM retail_sales
WHERE YEAR(`Order Date`)=2017
) as t
;

-- Total ventas MES a MES

-- seteamos los nombres de los meses en español
SET lc_time_names = 'es_ES'; 

Select month(`Order Date`) as `Numero de mes`,
CONCAT(
        UPPER(LEFT(MONTHNAME(`Order Date`), 1)),
        LOWER(SUBSTRING(MONTHNAME(`Order Date`), 2))
    ) AS Mes,
CONCAT('$',sum(sales)) as ventas
from Retail_sales
where year(`Order Date`)=2017
group by `Numero de mes`, `Mes`
order by `Numero de mes` ASC;

-- TOP 5 estados por ventas 

SELECT 
State AS Estado,
CONCAT('$',sum(Sales)) AS `Total de ventas`
FROM retail_sales
WHERE year(`Order Date`)=2017
Group by State
Order by sum(Sales) desc
Limit 5;

-- Participacion de las categorias sobre la vental total

SELECT
category as categoria,
sum(Sales) as 'Total de ventas',
CONCAT(
ROUND(
(sum(Sales)/ (SELECT sum(Sales) from retail_sales where year (`Order Date`)=2017))*100
,2)
,'%') AS 'Porcentaje de participacion'
FROM retail_sales
WHERE YEAR (`Order Date`)=2017
GROUP BY categoria
ORDER BY 'Total de venta';


-- Rango de descuentos

SELECT sum(quantity) as 'Cantidad de productos',
CASE
When discount=0 then '0%'
when discount >0 and discount <=0.2 then '1% a 20%'
when discount >0.2 and discount <=0.4 then '21% a 40%'
when discount >0.4 and discount <=0.6then '41% a 60%'
when discount >0.6 and discount <=0.8 then '61% a 80%'
else 'Mayor a 80%'
END as 'Rango de descuento'
From retail_sales
WHERE YEAR(`Order Date`)=2017
GROUP BY `Rango de descuento`
ORDER BY `Rango de descuento`;
