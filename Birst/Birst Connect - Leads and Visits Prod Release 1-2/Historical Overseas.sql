SELECT 
	Lead_id AS Email_id,
    lead_id AS Email_lead_id,
    type_of_lead AS lead_type,
    0 AS lead_paid,
    user_id,
    '' AS refer_tag,
    0 AS property_id,
    0 AS listing_id,
    country_code AS listing_country_code,
    branch_id,
    type_of_enquiry,
    '' AS property_address,
    '' AS property_outcode,
    '' AS property_incode,
    0 AS listing_price,
    0 AS lead_estimate,
    sent_date AS lead_creation_date,
    sent_date AS lead_sent_date
FROM 
	agent_leads_nopii
	JOIN agent_leads_sent USING (lead_id)
WHERE 
	sent_date > CURRENT_DATE - INTERVAL '20 days'
	AND type_of_lead <> 'temptme'
UNION
SELECT 
	Lead_id AS Email_id,
    lead_id AS Email_lead_id,
    listing_type AS lead_type,
    0 AS lead_paid,
    user_id,
    '' AS refer_tag,
    0 AS property_id,
    0 AS listing_id,
    listing_country_code,
    branch_id,
    type_of_enquiry,
    '' AS property_address,
    '' AS property_outcode,
    '' AS property_incode,
    0 AS listing_price,
    0 AS lead_estimate,
    sent_date AS lead_creation_date,
    sent_date AS lead_sent_date
FROM source_listing_agent_leads_nopii
WHERE sent_date > CURRENT_DATE - INTERVAL '10 days'