
---------------------------------------------------------------------
-- DimCustomer
select
    FirstName,
    MiddleName,
    LastName,
    FullName = IIF (MiddleName is null, FirstName + ' ' + LastName, FirstName + ' '+ MiddleName + ' ' + LastName)
from DimCustomer

alter table DimCustomer
add FullName NVARCHAR(50)

update DimCustomer
set FullName = IIF (MiddleName is null, FirstName + ' ' + LastName, FirstName + ' '+ MiddleName + ' ' + LastName)

update DimCustomer
set Gender = IIF (Gender = 'M', 'Male', 'Female')


---------------------------------------------------------------------
-- DimProduct

-- Determined cases for removing null values

select ProductDetail
FROM (
select *
    from DimProduct
    where ProductDetail LIKE '__ %'
        OR ProductDetail LIKE '%Nut%'
        or ProductDetail like '%Washer%'
        or ProductDetail like '%Paint%'
        or LEFT(ProductDetail,4) = 'Seat'
        or ProductDetail like '%Race%'
        or ProductDetail like '%Ball%'
        or ProductDetail like '%Metal%'
        or ProductDetail like '%Bolt%'
        or ProductDetail like '%Rear%'
        or ProductDetail like '%Tube%'
        or ProductDetail like '%Touring%'
        or ProductDetail like '%Caps%'
        or ProductDetail like '%Chain%'
        or ProductDetail like '%Decal%'
        or ProductDetail like '%Fork%'
        or ProductDetail like '%Derailleur%'
        or ProductDetail like '%Pulley%'
        or ProductDetail = 'Blade'
        or ProductDetail = 'Reflector'
        or ProductDetail = 'Freewheel'
        or ProductDetail = 'Spokes'
        or ProductDetail = 'Stem'
        or ProductDetail = 'Steerer'
        or ProductDetail = 'Lock Ring'
        -- and ModelName is NULL
) as case_tbl
where ModelName is NULL


-- REMOVING NULL VALUES USING UPDATE, CASE WHEN, IIF

update DimProduct
set ModelName = SUBSTRING(ProductDetail,4,LEN(ProductDetail))
where ProductDetail LIKE '__ %' and ModelName is NULL


update DimProduct
set ModelName = CASE 
        WHEN ProductDetail = 'Chainring Nut' THEN RIGHT(ProductDetail,3)
        WHEN ProductDetail like 'Thin-Jam Hex%' THEN SUBSTRING(ProductDetail,10,7)
        WHEN LEFT(ProductDetail,3) = 'Hex' THEN LEFT(ProductDetail,7)
        WHEN LEFT(ProductDetail,4) = 'Lock' THEN LEFT(ProductDetail,8)
        ELSE SUBSTRING(ProductDetail,10,8)
    END
where ProductDetail LIKE '%Nut%'


update DimProduct
set ModelName = CASE 
        WHEN LEFT(ProductDetail,4) = 'Flat' or LEFT(ProductDetail,4) = 'Lock' THEN CONCAT(LEFT(ProductDetail,4),' ',SUBSTRING(ProductDetail,6,6))
        WHEN ProductDetail LIKE '%External%' or ProductDetail LIKE '%Internal%' THEN CONCAT(LEFT(ProductDetail,8),' ',SUBSTRING(ProductDetail,15,6))
        ELSE RIGHT(ProductDetail,6)
    END
where ProductDetail LIKE '%Washer%'


update DimProduct
set ModelName = LEFT(ProductDetail,5)
where ProductDetail like '%Paint%'


update DimProduct
set ModelName = LEFT(ProductDetail,4)
where LEFT(ProductDetail,4) = 'Seat' and ModelName is NULL


update DimProduct
set ModelName = RIGHT(ProductDetail,4)
where ProductDetail like '%Race%'


update DimProduct
set ModelName = 'Ball Bearing'
where ProductDetail like '%Ball%'


update DimProduct
set ModelName = LEFT(ProductDetail,5)
where ProductDetail LIKE '%Metal%'


update DimProduct
set ModelName = 'Blade'
where ProductDetail = 'Blade'


update DimProduct
set ModelName = 'Reflector'
where ProductDetail = 'Reflector'


update DimProduct
set ModelName = 'Freewheel'
where ProductDetail = 'Freewheel'


update DimProduct
set ModelName = 'Spokes'
where ProductDetail = 'Spokes'


update DimProduct
set ModelName = 'Stem'
where ProductDetail = 'Stem'


update DimProduct
set ModelName = 'Steerer'
where ProductDetail = 'Steerer'


update DimProduct
set ModelName = 'Lock Ring'
where ProductDetail = 'Lock Ring'


update DimProduct
set ModelName = 'Chain Stays'
where ProductDetail = 'Chain Stays'


UPDATE DimProduct
set ModelName = RIGHT(ProductDetail,4)
where ProductDetail LIKE '%Tube'


UPDATE DimProduct
set ModelName = LEFT(ProductDetail,9)
where ProductDetail LIKE '%Chainring%' and ModelName is NULL


UPDATE DimProduct
set ModelName = LEFT(ProductDetail,5)
where ProductDetail LIKE 'Decal%' and ModelName is NULL


UPDATE DimProduct
set ModelName = RIGHT(ProductDetail,4)
where ProductDetail LIKE '%Caps'


UPDATE DimProduct
set ModelName = LEFT(ProductDetail,4)
where ProductDetail LIKE 'Fork%' and ModelName is NULL


UPDATE DimProduct
set ModelName = IIF(LEFT(ProductDetail,5) = 'Front', SUBSTRING(ProductDetail,7,LEN(ProductDetail)), SUBSTRING(ProductDetail,6,LEN(ProductDetail)))
where ProductDetail LIKE '%Derailleur%' and ModelName is NULL


UPDATE DimProduct
set ModelName = RIGHT(ProductDetail,6)
where ProductDetail LIKE '%Pulley' and ModelName is NULL


UPDATE DimProduct
set ModelName = ProductDetail
where ModelName is NULL

