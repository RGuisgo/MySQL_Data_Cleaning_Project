-- World Life Expectancy data



SELECT *
FROM worldlifeexpectancy_stagging
;


-- Identifying duplicates

SELECT Country, COUNT(CONCAT(Country,Year)) AS ccount
FROM worldlifeexpectancy_stagging
GROUP BY Country,Year
HAVING COUNT(CONCAT(Country,Year)) > 1;


-- deleting duplicates

DELETE FROM worldlifeexpectancy_stagging
WHERE Row_ID IN (
SELECT Row_ID
FROM
(SELECT Row_ID,Country, CONCAT(Country,Year) AS ccount,
ROW_NUMBER() OVER(PARTITION BY CONCAT(Country,Year) ORDER BY Country,Row_ID) AS Dup
FROM worldlifeexpectancy_stagging) AS Dupp
WHERE Dup > 1
ORDER BY Country)
;

-- Standardization

SELECT Country, REPLACE(Country,'CÃ´te', 'Côte')
FROM worldlifeexpectancy_stagging;



UPDATE worldlifeexpectancy_stagging
SET Country = 
    CASE WHEN Country = "CÃ´te d'Ivoire" THEN REPLACE(Country,'CÃ´te', 'Côte')
    ELSE Country
    END;


-- WORKING WITH NULL VALUES

-- Inserting null to empty Status cells

SELECT  Status,
CASE 
    WHEN Status = '' THEN Status = "NAN"
    ELSE Status
END
FROM worldlifeexpectancy_stagging;

-- Updating

UPDATE worldlifeexpectancy_stagging
SET Status = CASE 
    WHEN Status =  ""  THEN Status = "NAN"
    ELSE Status
END;



--  Inserting the known status

SELECT Country, Status,
CASE 
    WHEN Country = 'Afghanistan' AND Status = "0" THEN REPLACE(Status, "0" ,'Developing')
    WHEN Country = 'Albania' AND Status = "0" THEN REPLACE(Status, "0" ,'Developing')
    WHEN Country = 'Georgia' AND Status = "0" THEN REPLACE(Status, "0" ,'Developing')
    WHEN Country = 'United States of America' AND Status = "0" THEN REPLACE(Status, "0" ,'Developed')
    WHEN Country = 'Vanuatu' AND Status = "0" THEN   REPLACE(Status, "0" ,'Developing')
    WHEN Country = 'Zambia' AND Status = "0" THEN  REPLACE(Status, "0" ,'Developing')
    ELSE Status
END
FROM worldlifeexpectancy_stagging;


-- Updating


UPDATE worldlifeexpectancy_stagging
SET Status = CASE 
     WHEN Country = 'Afghanistan' AND Status = "0" THEN REPLACE(Status, "0" ,'Developing')
    WHEN Country = 'Albania' AND Status = "0" THEN REPLACE(Status, "0" ,'Developing')
    WHEN Country = 'Georgia' AND Status = "0" THEN REPLACE(Status, "0" ,'Developing')
    WHEN Country = 'United States of America' AND Status = "0" THEN REPLACE(Status, "0" ,'Developed')
    WHEN Country = 'Vanuatu' AND Status = "0" THEN   REPLACE(Status, "0" ,'Developing')
    WHEN Country = 'Zambia' AND Status = "0" THEN  REPLACE(Status, "0" ,'Developing')
    ELSE Status
END;


-- Inserting Average of the value before and after  to empty Life expectancy cells

SELECT  `Life expectancy`,
CASE 
    WHEN `Life expectancy` = ''  THEN  ROUND(COALESCE(LAG(`Life expectancy`,1) OVER(ORDER BY Row_ID)) + COALESCE(LEAD(`Life expectancy`,1) OVER(ORDER BY Row_ID)) / 2,1)
    ELSE `Life expectancy`
END
FROM worldlifeexpectancy_stagging;


-- Updating

UPDATE worldlifeexpectancy_stagging w
JOIN (
    SELECT Row_ID,
           ROUND(COALESCE(LAG(`Life expectancy`, 1) OVER (ORDER BY Row_ID)) + COALESCE(LEAD(`Life expectancy`, 1) OVER (ORDER BY Row_ID)) / 2, 1) AS new_value
    FROM worldlifeexpectancy_stagging
) t ON w.Row_ID = t.Row_ID
SET w.`Life expectancy` = 
    CASE
        WHEN w.`Life expectancy` = '' THEN t.new_value
        ELSE w.`Life expectancy`
    END;


-- Checking for Outliers


-- Life expectancy

SELECT *
FROM (SELECT Country, 
CASE WHEN
    w.`Life expectancy` > ( SELECT round(AVG(`Life expectancy`) + 3*STD(`Life expectancy`),1) FROM  worldlifeexpectancy_stagging)
    OR w.`Life expectancy` < (SELECT round(AVG(`Life expectancy`) - 3*STD(`Life expectancy`),1) FROM  worldlifeexpectancy_stagging) THEN 'Outliers'
    ELSE 'Not_outlier'
END AS Outlier_life_expectancy
FROM  worldlifeexpectancy_stagging w) AS subquery
WHERE Outlier_life_expectancy = 'Outliers';


-- Updating

UPDATE worldlifeexpectancy_stagging w
JOIN (
    SELECT 
        round(AVG(`Life expectancy`),1) AS avg_life_expectancy, 
        round(STD(`Life expectancy`),1) AS std_life_expectancy
    FROM worldlifeexpectancy_stagging
) t
SET w.`Life expectancy` = 
    CASE 
        WHEN w.`Life expectancy` > (t.avg_life_expectancy + 3 * t.std_life_expectancy)
        THEN (t.avg_life_expectancy + 3 * t.std_life_expectancy) -- Upper limit
        WHEN w.`Life expectancy` < (t.avg_life_expectancy - 3 * t.std_life_expectancy)
        THEN (t.avg_life_expectancy - 3 * t.std_life_expectancy) -- Lower limit
        ELSE w.`Life expectancy` -- Keep the value if within range
    END
WHERE w.`Life expectancy` > (t.avg_life_expectancy + 3 * t.std_life_expectancy)
   OR w.`Life expectancy` < (t.avg_life_expectancy - 3 * t.std_life_expectancy);




-- Adult mortality

SELECT *
FROM (SELECT Country, 
CASE WHEN
    w.`Adult Mortality` >( SELECT round(AVG(`Adult Mortality`) + 3*STD(`Adult Mortality`),1) FROM  worldlifeexpectancy_stagging)
    OR w.`Adult Mortality` < (SELECT round(AVG(`Adult Mortality`) - 3*STD(`Adult Mortality`),1) FROM  worldlifeexpectancy_stagging) THEN 'Outliers'
    ELSE 'Not_outlier'
END AS Outlier_Adult_Mortality
FROM  worldlifeexpectancy_stagging  w)AS subquery
WHERE Outlier_Adult_Mortality = 'Outliers';


-- Updating

UPDATE worldlifeexpectancy_stagging w
JOIN (
    SELECT
        round(AVG(`Adult Mortality`),1) AS avg_Adult_Mortality, 
        round(STD(`Adult Mortality`),1) AS std_Adult_Mortality
    FROM worldlifeexpectancy_stagging
) t 
SET w.`Adult Mortality` = 
    CASE 
        WHEN w.`Adult Mortality` > (t.avg_Adult_Mortality + 3 * t.std_Adult_Mortality)
        THEN (t.avg_Adult_Mortality + 3 * t.std_Adult_Mortality) -- Upper limit
        WHEN w.`Adult Mortality` < (t.avg_Adult_Mortality - 3 * t.std_Adult_Mortality)
        THEN (t.avg_Adult_Mortality - 3 * t.std_Adult_Mortality) -- Lower limit
        ELSE w.`Adult Mortality` -- Keep the value if within range
    END
WHERE w.`Adult Mortality` > (t.avg_Adult_Mortality + 3 * t.std_Adult_Mortality)
  OR  w.`Adult Mortality` < (t.avg_Adult_Mortality + 3 * t.std_Adult_Mortality);





-- infant deaths

SELECT *
FROM ( SELECT Country,
CASE WHEN `infant deaths` > (SELECT round(AVG(`infant deaths`) + 3*STD(`infant deaths`),1) FROM worldlifeexpectancy_stagging)
    OR `infant deaths` < (SELECT round(AVG(`infant deaths`) - 3*STD(`infant deaths`),1) FROM worldlifeexpectancy_stagging) THEN 'Outlier'
    ELSE 'Not_outlier'
END AS Outlier_infant_deaths
FROM worldlifeexpectancy_stagging) w
WHERE Outlier_infant_deaths = 'Outlier';



-- Updating

UPDATE worldlifeexpectancy_stagging w
JOIN (
    SELECT 
        round(AVG(`infant deaths`),1) AS avg_infant_deaths, 
        round(STD(`infant deaths`),1) AS std_infant_deaths
    FROM worldlifeexpectancy_stagging
) t
SET w.`infant deaths` = 
    CASE 
        WHEN w.`infant deaths` > (t.avg_infant_deaths + 3 * t.std_infant_deaths)
        THEN (t.avg_infant_deaths + 3 * t.std_infant_deaths) -- Upper limit
        WHEN w.`infant deaths` < (t.avg_infant_deaths - 3 * t.std_infant_deaths)
        THEN (t.avg_infant_deaths - 3 * t.std_infant_deaths) -- Lower limit
        ELSE w.`infant deaths` -- Keep the value if within range
    END
WHERE w.`infant deaths` > (t.avg_infant_deaths + 3 * t.std_infant_deaths) OR w.`infant deaths` < (t.avg_infant_deaths + 3 * t.std_infant_deaths);


-- Percentage expenditure

SELECT *
FROM ( SELECT country,
CASE WHEN `percentage expenditure` > (SELECT round(AVG(`percentage expenditure`) + 3*STD(`percentage expenditure`),1) FROM worldlifeexpectancy_stagging)
OR  `percentage expenditure` < (SELECT round(AVG(`percentage expenditure`) - 3*STD(`percentage expenditure`),1) FROM worldlifeexpectancy_stagging)
THEN 'Outliers'
ELSE 'Not_Outliers'
END AS Outlier_percentage_expenditure
FROM worldlifeexpectancy_stagging) w
WHERE Outlier_percentage_expenditure = 'Outliers' ;


-- Updating  percentage expenditure

UPDATE worldlifeexpectancy_stagging w
JOIN( SELECT round(AVG(`percentage expenditure`),1) AS avg_percentage_expenditure,
round(STD(`percentage expenditure`),1) AS std_percentage_expenditure
FROM worldlifeexpectancy_stagging) AS t
SET `percentage expenditure` = 
CASE 
    WHEN `percentage expenditure` >  (t.avg_percentage_expenditure + 3*t.std_percentage_expenditure) THEN round((t.avg_percentage_expenditure + 3*t.std_percentage_expenditure),1)
    WHEN  `percentage expenditure` <  (t.avg_percentage_expenditure - 3*t.std_percentage_expenditure) THEN round((t.avg_percentage_expenditure - 3*t.std_percentage_expenditure),1)
    ELSE `percentage expenditure`
END 
WHERE w.`percentage expenditure` > (t.avg_percentage_expenditure + 3*t.std_percentage_expenditure) OR w.`percentage expenditure` < (t.avg_percentage_expenditure - 3*t.std_percentage_expenditure)
;



-- Measles

SELECT *
FROM ( SELECT country,
CASE WHEN `Measles` > (SELECT round(AVG(`Measles`) + 3*STD(`Measles`),1) FROM worldlifeexpectancy_stagging)
OR  `Measles` < (SELECT round(AVG(`Measles`) - 3*STD(`Measles`),1) FROM worldlifeexpectancy_stagging)
THEN 'Outliers'
ELSE 'Not_Outliers'
END AS Outlier_Measles
FROM worldlifeexpectancy_stagging) w
WHERE Outlier_Measles = 'Outliers' ;


-- Updating  Measles

UPDATE worldlifeexpectancy_stagging w
JOIN( SELECT round(AVG(`Measles`),1) AS avg_Measles,
round(STD(`Measles`),1) AS std_Measles
FROM worldlifeexpectancy_stagging) AS t
SET `Measles` = 
CASE 
    WHEN `Measles` >  (t.avg_Measles + 3*t.std_Measles) THEN round((t.avg_Measles + 3*t.std_Measles),1)
    WHEN  `Measles` <  (t.avg_Measles - 3*t.std_Measles) THEN round((t.avg_Measles - 3*t.std_Measles),1)
    ELSE `Measles`
END 
WHERE w.`Measles` > round((t.avg_Measles + 3*t.std_Measles),1) OR w.`Measles` < round((t.avg_Measles - 3*t.std_Measles),1)
;

-- BMI

SELECT *
FROM ( SELECT country,
CASE WHEN `BMI` > (SELECT round(AVG(`BMI`) + 3*STD(`BMI`),1) FROM worldlifeexpectancy_stagging)
OR  `BMI` < (SELECT round(AVG(`BMI`) - 3*STD(`BMI`),1) FROM worldlifeexpectancy_stagging)
THEN 'Outliers'
ELSE 'Not_Outliers'
END AS Outlier_BMI
FROM worldlifeexpectancy_stagging) w
WHERE Outlier_BMI = 'Outliers' ;




-- under - five deaths

SELECT *
FROM ( SELECT country,
CASE WHEN `under-five deaths` > (SELECT round(AVG(`under-five deaths`) + 3*STD(`under-five deaths`),1) FROM worldlifeexpectancy_stagging)
OR  `under-five deaths` < (SELECT round(AVG(`under-five deaths`) - 3*STD(`under-five deaths`),1) FROM worldlifeexpectancy_stagging) THEN 'Outliers'
ELSE 'Not_Outliers'
END AS Outlier_under_five 
FROM worldlifeexpectancy_stagging) w
WHERE Outlier_under_five = 'Outliers' ;



-- Updating  under-five deaths 


UPDATE worldlifeexpectancy_stagging w
JOIN( SELECT round(AVG(`under-five deaths`),1) AS avg_under_five,
round(STD(`under-five deaths`),1) AS std_under_five
FROM worldlifeexpectancy_stagging) AS t
SET `under-five deaths` = 
CASE 
    WHEN `under-five deaths` >  (t.avg_under_five + 3*t.std_under_five) THEN round((t.avg_under_five + 3*t.std_under_five),1)
    WHEN  `under-five deaths` <  (t.avg_under_five - 3*t.std_under_five) THEN round((t.avg_under_five - 3*t.std_under_five),1)
    ELSE `under-five deaths`
END 
WHERE w.`under-five deaths` > round((t.avg_under_five + 3*t.std_under_five),1) OR w.`under-five deaths` < round((t.avg_under_five - 3*t.std_under_five),1)
;


-- Polio

SELECT *
FROM ( SELECT country,
CASE WHEN `Polio` > (SELECT round(AVG(`Polio`) + 3*STD(`Polio`),1) FROM worldlifeexpectancy_stagging)
OR  `Polio` < (SELECT round(AVG(`Polio`) - 3*STD(`Polio`),1) FROM worldlifeexpectancy_stagging) THEN 'Outliers'
ELSE 'Not_Outliers'
END AS Outlier_Polio 
FROM worldlifeexpectancy_stagging) w
WHERE Outlier_Polio = 'Outliers' ;



-- Updating  Polio


UPDATE worldlifeexpectancy_stagging w
JOIN( SELECT round(AVG(`Polio`),1) AS avg_Polio,
round(STD(`Polio`),1) AS std_Polio
FROM worldlifeexpectancy_stagging) AS t
SET `Polio` = 
CASE 
    WHEN `Polio` >  (t.avg_Polio + 3*t.std_Polio) THEN round((t.avg_Polio + 3*t.std_Polio),1)
    WHEN  `Polio` < (t.avg_Polio - 3*t.std_Polio) THEN round((t.avg_Polio - 3*t.std_Polio),1)
    ELSE `Polio`
END 
WHERE w.`Polio` > round((t.avg_Polio + 3*t.std_Polio),1) OR w.`Polio` < round((t.avg_Polio - 3*t.std_Polio),1)
;



-- Diphtheria

SELECT *
FROM ( SELECT country,
CASE WHEN `Diphtheria` > (SELECT round(AVG(`Diphtheria`) + 3*STD(`Diphtheria`),1) FROM worldlifeexpectancy_stagging)
OR  `Diphtheria` < (SELECT round(AVG(`Diphtheria`) - 3*STD(`Diphtheria`),1) FROM worldlifeexpectancy_stagging) THEN 'Outliers'
ELSE 'Not_Outliers'
END AS Outlier_Diphtheria  
FROM worldlifeexpectancy_stagging) w
WHERE Outlier_Diphtheria  = 'Outliers' ;



-- Updating  Diphtheria


UPDATE worldlifeexpectancy_stagging w
JOIN( SELECT round(AVG(`Diphtheria`),1) AS avg_Diphtheria ,
round(STD(`Diphtheria`),1) AS std_Diphtheria 
FROM worldlifeexpectancy_stagging) AS t
SET `Diphtheria` = 
CASE 
    WHEN `Diphtheria` >  (t.avg_Diphtheria + 3*t.std_Diphtheria) THEN round((t.avg_Diphtheria  + 3*t.std_Diphtheria),1)
    WHEN  `Diphtheria` < (t.avg_Diphtheria - 3*t.std_Diphtheria) THEN round((t.avg_Diphtheria - 3*t.std_Diphtheria),1)
    ELSE `Diphtheria`
END 
WHERE w.`Diphtheria` > round((t.avg_Diphtheria + 3*t.std_Diphtheria),1) OR w.`Diphtheria` < round((t.avg_Diphtheria - 3*t.std_Diphtheria),1)
;


-- GDP


SELECT *
FROM ( SELECT country,
CASE WHEN `GDP` > (SELECT round(AVG(`GDP`) + 3*STD(`GDP`),1) FROM worldlifeexpectancy_stagging)
OR  `GDP` < (SELECT round(AVG(`GDP`) - 3*STD(`GDP`),1) FROM worldlifeexpectancy_stagging) THEN 'Outliers'
ELSE 'Not_Outliers'
END AS Outlier_GDP  
FROM worldlifeexpectancy_stagging) w
WHERE Outlier_GDP  = 'Outliers' ;



-- Updating  GDP


UPDATE worldlifeexpectancy_stagging w
JOIN( SELECT round(AVG(`GDP`),1) AS avg_GDP ,
round(STD(`GDP`),1) AS std_GDP 
FROM worldlifeexpectancy_stagging) AS t
SET `GDP` = 
CASE 
    WHEN `GDP` >  (t.avg_GDP + 3*t.std_GDP) THEN round((t.avg_GDP  + 3*t.std_GDP),1)
    WHEN  `GDP` < (t.avg_GDP - 3*t.std_GDP) THEN round((t.avg_GDP - 3*t.std_GDP),1)
    ELSE `GDP`
END 
WHERE w.`GDP` > round((t.avg_GDP + 3*t.std_GDP),1) OR w.`GDP` < round((t.avg_GDP - 3*t.std_GDP),1)
;