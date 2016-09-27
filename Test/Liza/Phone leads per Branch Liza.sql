/*The number of phone leads are total phone leads sent to that branch.*/

--Original

SELECT 
  date_part(y,call_start) as year, 
  date_part(mon,call_start) as month, 
  l.branch_id, 
  count(distinct id) as total_phone_leads
FROM agent_phone_leads_nopii as l
WHERE 
  call_start>='2016-07-01' 
  AND branch_id in 
    ( SELECT c.branch_id 
      FROM 
        contracts_migration as c
        INNER JOIN agent_packages as p on p.agent_package_id=c.agent_package_id
      WHERE package_type='commercial'
    )
GROUP BY 1,2,3
ORDER BY 1,2,3
LIMIT 100

--Edited

SELECT 
  DATEPART(YEAR, l.call_start) AS year, DATEPART(MONTH, l.call_start) AS month, 
  l.branch_id, 
  COUNT(DISTINCT l.id) AS total_phone_leads
FROM agent_phone_leads_nopii AS l
WHERE 
  l.call_start >= '2016-07-01' 
  AND l.branch_id IN 
    ( SELECT c.branch_id 
      FROM 
        contracts_migration AS c
        INNER JOIN agent_packages AS p ON p.agent_package_id = c.agent_package_id
      WHERE p.package_type = 'commercial'
    )
GROUP BY 1,2,3
ORDER BY 1,2,3
LIMIT 100