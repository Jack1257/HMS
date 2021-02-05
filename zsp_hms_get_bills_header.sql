USE [HMS]
GO
/****** Object:  StoredProcedure [dbo].[zsp_hms_get_bills_header] ******/
/****** Разработка - Степаненко Е.В. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
----------------------------------------------------------------------------------------------------
-- Процедура возвращает счета, которые нужно обработать
ALTER PROCEDURE [dbo].[zsp_hms_get_bills_header]
   @DateIn datetime='20190801',
   @DateOut datetime='20190831',
   @hms tinyint=0
AS
   SET NOCOUNT ON -- Запрет вывода количества строк в состав результирующего набора
----------------------------------------------------------------------------------------------------
-- Если входной параметр @hms равен 0, выполняется процедура dbo.zsp_hms_get_data_by_period,
-- которая обновляет таблицу текущих счетов dbo.BillsCurrent
   IF @hms=0 EXEC [HMS].[dbo].[zsp_hms_get_data_by_period] @DateIn, @DateOut
----------------------------------------------------------------------------------------------------
   SELECT 
	 CONVERT(varchar, B.CloseDate, 104) AS Data	
	,CONVERT(varchar, MAX(B.BillNumber)) AS BillNumber
	,B.GroupOfPay
	,B.ValuteID
	,CONVERT(varchar, B.CompanyID_1C) AS CompanyID
	,CASE B.Company_Name
		WHEN '' THEN 'Не заполнено' -- Если поле содержит пустую строку, то выводится "Не заполнено"
		ELSE B.Company_Name
	 END AS CompanyName

	,B.Fact_Flag
	,B.HotelID 
	,CONVERT(varchar, SUM(B.TotalSum)) AS TotalSum
   FROM [HMS].[db_pms].[BillsCurrent] AS B 
   LEFT JOIN [HMS].[db_pms].[FinishedBills] AS F ON B.BillNumber=F.BillNumber AND F.FlagFinished=1
   WHERE F.BillNumber IS NULL
	AND B.CloseDate BETWEEN @DateIn AND @DateOut
   GROUP BY
	 B.CloseDate
	,B.GroupOfPay
	,B.ValuteID
	,B.CompanyID_1C
	,B.Company_Name
	,B.Fact_Flag
	,B.HotelID
   ORDER BY
	 Data
	,BillNumber
	,HotelID
----------------------------------------------------------------------------------------------------
