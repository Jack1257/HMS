USE [HMS]
GO
/****** Object:  StoredProcedure [dbo].[zsp_hms_get_bills_journal] ******/
/****** Разработка - Степаненко Е.В. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Процедура возвращает развёрнутую информацию по счетам, которые нужно обработать
ALTER PROCEDURE [dbo].[zsp_hms_get_bills_journal]
   @DateIn datetime='20190801',
   @DateOut datetime='20190831'
AS
   SET NOCOUNT ON -- Запрет вывода количества строк в состав результирующего набора
----------------------------------------------------------------------------------------------------
   SELECT
	 CONVERT(varchar, B.CloseDate, 104) AS Data
	,CONVERT(varchar, B.BillNumber) AS BillNumber
	,B.GroupOfPay
	,B.ServiceCode AS ServiceCode
	,B.Service_Name AS ServiceName
	,B.ValuteID
	,CONVERT(varchar, B.CompanyID_1C) AS CompanyID
	,CASE B.Company_Name
		WHEN '' THEN 'Не заполнено' -- Если поле содержит пустую строку, то выводится "Не заполнено"
		ELSE B.Company_Name
	 END AS CompanyName
	,B.HotelID
	,CONVERT(varchar, B.Price) AS Price
	,CONVERT(varchar, B.Quantity) AS Quantity
	,CONVERT(varchar, B.TotalSum) AS TotalSum
   FROM [HMS].[db_pms].[BillsCurrent] AS B 
   LEFT JOIN [HMS].[db_pms].[FinishedBills] AS F ON B.BillNumber=F.BillNumber
   WHERE F.BillNumber IS NULL
	AND B.CloseDate BETWEEN @DateIn AND @DateOut
   ORDER BY
	 Data
	,GroupOfPay
	,HotelID
	,B.BillNumber
----------------------------------------------------------------------------------------------------
