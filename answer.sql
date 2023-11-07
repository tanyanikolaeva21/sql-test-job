--1 задача:
SELECT TOP 2 --возвращает 2 первых значения 
   dbo.FD_Bills.C_number -- явно указан нужный столбец C_number из конкретной таблицы
   , dbo.SD_Subscrs.c_number AS c_subscr -- явно указан другой нужный столбец c_number с присвоением псевдонима
   , CONVERT(varchar, dbo.FD_Bills.D_date, 104) AS d_date -- конвертирование даты в формат 104, т.е вывод типа DD.MM.YYYY
   , N_Amount
FROM dbo.FD_Bills
JOIN dbo.SD_Subscrs ON dbo.SD_Subscrs.lINk = dbo.FD_Bills.f_subscr -- присоединение таблицы с номерами лс по ключу таблиц, у каждой таблицы свой ключ
WHERE dbo.FD_Bills.d_date BETWEEN DATEADD(day, -12, GETDATE()) AND DATEADD(day, -8, GETDATE()); -- выборка дат, находящихся между 12 и 8 днями до текущей даты
GO

-- 2 задача:
SELECT DISTINCT --возвращение уникального значения суммы
   N_Amount
FROM dbo.FD_Bills
WHERE C_Sale_Items = 'ХВС'; -- выборка по ключевому значению
GO

-- 3 задача:
SELECT 
	C_sale_items
	, AVG(N_Amount) -- нахождение среднего значения
FROM dbo.FD_Bills
GROUP BY C_sale_items --группировка по названию 
HAVING AVG(N_Amount)>120; --выборка из средних сгруппированных значений по условию
GO

-- 4 задача:
SELECT 
	CONCAT(YEAR(d_date), FORMAT(d_date, 'MM')) AS N_Month -- коктаниция даты в нужном формате- год месяц без пробелови и доп.знаков
	, C_sale_items
	, SUM(n_amount) AS N_amount_SUM -- сумма значений по столбцу n_amount с присвоением псевдонима
FROM dbo.FD_Bills
GROUP BY CONCAT(YEAR(d_date), FORMAT(d_date, 'MM')), C_sale_items -- группировка данных сначала по дате, затем по названию
ORDER BY CONCAT(YEAR(d_date), FORMAT(d_date, 'MM')); -- сортировка по возрастанию даты
GO

-- 5 задача:
SELECT 
	C_sale_items
	, [201812]
	, [201901]
	, [201902] -- возвращение наименования и сформированных интервалов по месяцам
FROM (
SELECT 
	CONCAT(YEAR(d_date)
	, FORMAT(d_date, 'MM')) AS N_Month
	, C_sale_items
	, n_amount 
FROM dbo.FD_Bills) AS datatable -- создание временной таблицы datatable, для последуюго преобразования в сводную
PIVOT (SUM(n_amount) FOR N_Month IN ([201812], [201901], [201902])) AS pivottable; -- трансформирует временную таблицу размещая данные из строк в столбцы, объединяя по сумме значений
GO

-- 6 задача:
SELECT 
	d_date
	, c_number
	, n_amount
	, n_amount_b -- n_amount_b рассчитывается в подзапросе с использованием функции LAG
FROM ( SELECT 
	d_date
	, c_number
	, n_amount
	, LAG(n_amount) OVER (ORDER BY d_date) AS n_amount_b -- подзапрос для получения предыдущего значения суммы, отсортированных по дате
	FROM dbo.FD_Bills ) AS datatable
	WHERE n_amount > n_amount_b OR n_amount_b IS NULL -- выборка данных, где сумма начисления больше предыдущего начисления  или предыдущее начисление отсутствует
	ORDER BY d_date
GO

-- 7 задача:
SELECT 
	CONCAT(c_secondname, ' ', Left(c_firstname, 1), '.') AS c_fio -- конкатинация фамилии, пробела, первого левого символа имени, точки с присвоением псевдонима
	, dbo.DD_Docs.c_number
	, CONVERT(varchar, dbo.DD_Docs.D_date, 104) AS d_date -- конвертирование даты в формат 104, т.е вывод типа DD.MM.YYYY
FROM dbo.DD_Docs
JOIN dbo.SD_Subscrs on dbo.SD_Subscrs.LINK = dbo.DD_Docs.F_Subscr  -- присоединение необходимой таблицы по ключу, в которой содержится дата рождения
WHERE C_Address LIKE('%Ленин%') AND D_BirthDate < DATEADD(YEAR, -18, GETDATE()); -- выборка по адресу, в котором содержится 'Ленин' и одновременно при этом дата рождения раньше чем дата, находящаяся в 18 годах от текущей даты
GO

-- 8 задача:
WITH par_table AS ( -- создание рекурсивной таблицы
    SELECT *
    FROM dbo.dd_docs
	WHERE c_number = '4-д/1' -- возвращает все данные соответствующие условию
    UNION ALL 
	SELECT b.*
    FROM dbo.dd_docs AS b
    INNER JOIN par_table AS a ON a.F_Docs = b.LINK) -- объединяет полученный результат с самой таблицей до тех пор пока не выберутся все строки

SELECT 
	c_number
	, d_date
FROM par_table
ORDER BY d_date;
