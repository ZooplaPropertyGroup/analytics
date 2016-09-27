/* Check Device, Market, Market Type, Device Category */

UPDATE public.fullfeed
SET platform = 'Mobile'
WHERE platform in ('mob','mobi','mobil','mobile','m','mo');

UPDATE public.fullfeed
SET platform = 'App'
WHERE platform in ('app');

UPDATE public.fullfeed
SET platform = 'Desktop'
WHERE platform in ('desktop','deskto','desk');

UPDATE public.fullfeed
SET platform = 'Native App'
WHERE platform in ('native-app');

UPDATE public.fullfeed
SET platform = 'Unknown'
WHERE platform = ' ';



UPDATE public.fullfeed
SET device = 'Unknown'
WHERE device = 'na';

UPDATE public.fullfeed
SET "device category" = 'Unknown'
WHERE "device category" IS NULL;

UPDATE public.fullfeed
SET "device category" = 'Desktop'
WHERE "device category" = 'desktop';

UPDATE public.fullfeed
SET "device category" = 'Mobile'
WHERE "device category" = 'mobile';

UPDATE public.fullfeed
SET "device category" = 'Tablet'
WHERE "device category" = 'tablet';

UPDATE public.fullfeed
SET device = 'Unknown', "device category" = 'Unknown', platform = 'Unknown'
where platform ='App'
and lead = 'Phone';

UPDATE public.fullfeed
SET market = 'Unknown'
---, markettype = 'Unknown'
WHERE market = 'na';


UPDATE public.fullfeed
SET market = 'Unknown', markettype = 'Unknown'
WHERE enquirytypekey = '(not set)__Results';

UPDATE public.fullfeed
SET market = 'UK Residential Valuation', markettype = 'UK Residential Valuation'
WHERE enquirytypekey = 'Estimate run_Estimate';

UPDATE public.fullfeed
SET market = 'Unknown', markettype = 'Unknown'
WHERE market = 'na' and enquirytypekey = '_'

UPDATE public.fullfeed
SET market = 'UK Residential', markettype = 'UK Residential'
WHERE enquirytypekey = '(not set)_AAA_Contact';

UPDATE public.fullfeed
SET market = 'UK Residential', markettype = 'UK Residential'
WHERE enquirytypekey = '(not set)_FA_Contact';

UPDATE public.fullfeed
SET market = 'UK Residential', markettype = 'UK Residential'
WHERE enquirytypekey = '(not set)_FA_Results';

UPDATE public.fullfeed
SET market = 'UK Residential', markettype = 'UK Residential'
WHERE enquirytypekey = '_AAA_Contact';

UPDATE public.fullfeed
SET market = 'UK Residential', markettype = 'UK Residential'
WHERE enquirytypekey = '_FA_Brochure';

UPDATE public.fullfeed
SET market = 'UK Residential', markettype = 'UK Residential'
WHERE enquirytypekey = '_FA_Contact';

UPDATE public.fullfeed
SET market = 'UK Residential', markettype = 'UK Residential'
WHERE enquirytypekey = '_FS_Results';

UPDATE public.fullfeed
SET market = 'UK Residential', markettype = 'UK Residential'
WHERE enquirytypekey = '_TR_Result';

UPDATE public.fullfeed
SET market = 'Commercial', markettype = 'Commercial'
WHERE enquirytypekey = 'Commercial Let__Results';

UPDATE public.fullfeed
SET market = 'Commercial', markettype = 'Commercial'
WHERE enquirytypekey = 'Commercial Let_FA_Results';

UPDATE public.fullfeed
SET market = 'Commercial', markettype = 'Commercial'
WHERE enquirytypekey = 'Commercial Sale__Results';

UPDATE public.fullfeed
SET market = 'UK Residential', markettype = 'UK Residential'
WHERE enquirytypekey = 'For Sale__Brochure';

UPDATE public.fullfeed
SET market = 'UK Residential', markettype = 'UK Residential'
WHERE enquirytypekey = 'For Sale__Results';


UPDATE public.fullfeed
SET market = 'UK Residential', markettype = 'UK Residential'
WHERE enquirytypekey = 'For Sale_FS_Results_Contact';

UPDATE public.fullfeed
SET market = 'UK Residential', markettype = 'UK Residential'
WHERE enquirytypekey = 'For Sale_TR_Contact';

UPDATE public.fullfeed
SET market = 'Developer', markettype = 'Developer'
WHERE enquirytypekey = 'Lessor_NH_Contact';

UPDATE public.fullfeed
SET market = 'UK Residential', markettype = 'UK Residential'
WHERE enquirytypekey = 'To Rent_FS_Contact'

UPDATE public.fullfeed
SET market = 'UK Residential', markettype = 'UK Residential'
WHERE enquirytypekey = 'To Rent_FS_Results_Contact'

UPDATE public.fullfeed
SET market = 'Developer', markettype = 'Developer'
WHERE enquirytypekey = 'To Rent_NH_Contact'

UPDATE public.fullfeed
SET market = 'UK Residential', markettype = 'UK Residential'
WHERE enquirytypekey = 'To Rent_TR_Brochure'

UPDATE public.fullfeed
SET market = 'UK Residential', markettype = 'UK Residential'
WHERE enquirytypekey = 'To Rent_TR_Results_Contact'

UPDATE public.fullfeed
SET market = 'UK Residential', markettype = 'UK Residential'
WHERE enquirytypekey = 'To%20Rent_TR_Contact'

UPDATE public.fullfeed
SET market = 'Developer', markettype = 'Developer'
WHERE enquirytypekey = 'Vendor_NH_Contact'



UPDATE public.fullfeed
SET markettype = 'UK Residential'
WHERE market = 'UK Residential';

UPDATE public.fullfeed
SET market = 'UK Residential'
WHERE markettype = 'UK Residential';

UPDATE public.fullfeed
SET markettype = 'Commercial'
WHERE market = 'Commercial';


UPDATE public.fullfeed
SET markettype = 'Unknown', market = 'Unknown'
WHERE market = 'na';


select markettype, market
from public.fullfeed
group by markettype,market

select platform, sum(fullfeed.noofvisits)
from public.fullfeed
group by fullfeed.platform