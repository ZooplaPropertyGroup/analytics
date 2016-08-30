-- TESTING GITHUB OUT
SELECT 
    outcode, 
    SUM(total_email_leads) email_leads, 
    SUM(total_phone_leads) phone_leads
FROM
(
    SELECT 
        b.outcode,
        COUNT(DISTINCT e.id) AS total_email_leads,
        0 AS total_phone_leads
    FROM 
        agent_email_leads_nopii AS e
        INNER JOIN agent_branches_nopii AS b ON b.branch_id = e.branch_id
        INNER JOIN postal_area_outcodes AS pac ON pac.outcode = b.outcode 
    WHERE 
        lead_sent_date >= '2016-01-01' 
        AND lead_sent_date < '2016-08-01'
    GROUP BY 1
    UNION ALL
    SELECT 
        b.outcode,
        0 AS total_email_leads,
        COUNT(DISTINCT l.id) AS total_phone_leads
    FROM 
        agent_phone_leads_nopii AS l
        INNER JOIN agent_branches_nopii AS b ON b.branch_id = l.branch_id
        INNER JOIN postal_area_outcodes AS pac ON pac.outcode = b.outcode 
    WHERE 
        call_start >= '2016-01-01' 
        AND call_start < '2016-08-01'
    GROUP BY 1
)
GROUP BY 1
ORDER BY 1
