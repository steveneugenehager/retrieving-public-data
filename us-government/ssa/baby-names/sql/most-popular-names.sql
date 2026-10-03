SELECT
  sex_code,
  first_name,
  SUM(birth_cnt) AS total_births,
  RANK() OVER (PARTITION BY sex_code ORDER BY SUM(birth_cnt) DESC) AS name_rank
FROM 
	raw_us_govt.baby_first_names
GROUP BY 
	sex_code
	, first_name
QUALIFY name_rank <= 10
ORDER BY 
	sex_code
	, name_rank
;
