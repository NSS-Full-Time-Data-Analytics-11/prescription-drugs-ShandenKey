--1. a. Which prescriber had the highest total number of claims (totaled over all drugs)? 
--Report the npi and the total number of claims.
SELECT DISTINCT npi, sum(total_claim_count) AS grand_total
FROM prescriber INNER JOIN prescription USING(npi)
GROUP BY npi
ORDER BY grand_total DESC
LIMIT 1;

--**b. Repeat the above, but this time report the nppes_provider_first_name, 
--nppes_provider_last_org_name, specialty_description, and the total number of claims.
SELECT DISTINCT npi, CONCAT(nppes_provider_first_name, ' ', nppes_provider_last_org_name) AS provider_name,
 specialty_description, SUM(total_claim_count) AS total_claim_count
FROM prescriber 
	JOIN prescription USING(npi)
GROUP BY npi, provider_name, specialty_description
ORDER BY total_claim_count DESC;
	
--2. a. Which specialty had the most total number of claims (totaled over all drugs)?
SELECT DISTINCT npi, specialty_description, total_claim_count
FROM prescriber
	JOIN prescription USING(npi)
ORDER BY total_claim_count DESC
LIMIT 1;


  --  b. Which specialty had the most total number of claims for opioids?
SELECT specialty_description, SUM(total_claim_count)
FROM prescriber
	INNER JOIN prescription USING(npi)
	INNER JOIN drug USING(drug_name)
WHERE drug.opioid_drug_flag = 'Y'
GROUP BY specialty_description
ORDER BY SUM(total_claim_count) DESC
LIMIT 1;
	
    --c. **Challenge Question:** Are there any specialties that appear in the prescriber table 
	--that have no associated prescriptions in the prescription table?
SELECT specialty_description
FROM prescriber
	JOIN prescription USING(npi)
WHERE total_claim_count IS NULL

	
SELECT * FROM prescriber JOIN prescription USING(npi)	
	--d. **Difficult Bonus:** *Do not attempt until you have solved all other problems!* 
	--For each specialty, report the percentage of total claims by that specialty which are for opioids. 
	--Which specialties have a high percentage of opioids?
	
	
--3.  a. Which drug (generic_name) had the highest total drug cost?
SELECT generic_name, SUM(total_drug_cost)AS total_drug_cost
FROM drug
JOIN prescription USING(drug_name)
GROUP BY generic_name
ORDER BY total_drug_cost DESC
LIMIT 1;

  --**b. Which drug (generic_name) has the hightest total cost per day? 
SELECT generic_name, ROUND(SUM(total_drug_cost)/SUM(total_day_supply),2) AS cost_per_day
FROM prescription
LEFT JOIN drug USING(drug_name)
GROUP BY generic_name
ORDER BY cost_per_day DESC
LIMIT 1;

  --**Bonus: Round your cost per day column to 2 decimal places. Google ROUND to see how this works.**
--INSERTED INTO ABOVE

--4. a. For each drug in the drug table, return the drug name and then a column named 'drug_type' which 
  --says 'opioid' for drugs which have opioid_drug_flag = 'Y', says 'antibiotic' for those drugs which .
  --have antibiotic_drug_flag = 'Y', and says 'neither' for all other drugs.

SELECT drug_name,
(CASE WHEN opioid_drug_flag = 'Y' THEN 'opiod'
 	  WHEN long_acting_opioid_drug_flag = 'Y' THEN 'opioid'
	  WHEN antibiotic_drug_flag = 'Y' THEN 'antibiotic'
	  ELSE 'neither'
	  END) AS drug_type
FROM drug;

    --b. Building off of the query you wrote for part a, determine whether more was 
	--spent (total_drug_cost) on opioids or on antibiotics. Hint: Format the total costs as MONEY 
	--for easier comparision.

SELECT 
CASE WHEN opioid_drug_flag = 'Y' THEN 'opiod'
 	  WHEN long_acting_opioid_drug_flag = 'Y' THEN 'opioid'
	  WHEN antibiotic_drug_flag = 'Y' THEN 'antibiotic'
	  ELSE 'neither'
	  END AS drug_type, SUM(total_drug_cost)AS total_cost_by_type	  
FROM drug INNER JOIN prescription AS pre USING(drug_name)
GROUP BY drug_type;



	
--5. a. How many CBSAs are in Tennessee? **Warning:** The cbsa table contains information for all states, 
--not just Tennessee.
SELECT COUNT(DISTINCT (cbsaname))
FROM cbsa
WHERE cbsaname LIKE '%TN%'


    --b. Which cbsa has the largest combined population? Which has the smallest? Report the CBSA name 
	--and total population.

--largest
SELECT cbsaname , SUM(population) AS population
FROM cbsa JOIN population USING(fipscounty)
GROUP BY cbsaname
ORDER BY population DESC
LIMIT 1;
--smallest
SELECT cbsaname, population
FROM cbsa JOIN population USING(fipscounty)
ORDER BY population
LIMIT 1;

    --c. What is the largest (in terms of population) county which is not included in a CBSA? Report the 
	--county name and population.
SELECT county, population
FROM population
	FULL JOIN cbsa USING(fipscounty)
	JOIN fips_county USING(fipscounty)
WHERE cbsa IS NULL
ORDER BY population DESC
LIMIT 1;
--6. a. Find all rows in the prescription table where total_claims is at least 3000. Report the 
--drug_name and the total_claim_count.
--THISONE:
SELECT drug_name, total_claim_count 
FROM prescription 
WHERE total_claim_count >3000
ORDER BY drug_name
	
    --b. For each instance that you found in part a, add a column that indicates whether the drug is 
	--an opioid.
SELECT drug_name, total_claim_count, opioid_drug_flag
FROM (SELECT npi, drug_name, total_claim_count 
	  FROM prescription 
	  WHERE total_claim_count >3000) AS claims_sum
	  JOIN drug USING(drug_name)
	  
	  
	
    --c. Add another column to you answer from the previous part which gives the prescriber 
	--first and last name associated with each row.
	  
SELECT drug_name, total_claim_count, opioid_drug_flag, CONCAT(nppes_provider_first_name,' ', 
		nppes_provider_last_org_name) AS provider_name
FROM (SELECT npi, drug_name, total_claim_count 
	  FROM prescription 
	  WHERE total_claim_count >3000) AS claims_sum
	  JOIN drug USING(drug_name)
	  JOIN prescriber USING(npi)	  

--7. The goal of this exercise is to generate a full list of all pain management specialists in 
--Nashville and the number of claims they had for each opioid. **Hint:** The results from 
--all 3 parts will have 637 rows.

    --a. First, create a list of all npi/drug_name combinations for pain management specialists 
	--(specialty_description = 'Pain Managment') in the city of Nashville (nppes_provider_city = 
	--'NASHVILLE'), where the drug is an opioid (opiod_drug_flag = 'Y'). 
	--**Warning:** Double-check your query before running it. You will only need to use the 
	--prescriber and drug tables since you don't need the claims numbers yet. 

SELECT prescriber.npi, drug.drug_name
FROM prescriber
CROSS JOIN drug
WHERE specialty_description ILIKE 'Pain%' AND (nppes_provider_city = 'NASHVILLE') 
		AND (opioid_drug_flag = 'Y')
GROUP BY prescriber.npi, drug.drug_name
ORDER BY prescriber.npi

    --b. Next, report the number of claims per drug per prescriber. Be sure to include all combinations, 
	--whether or not the prescriber had any claims. You should report the npi, the drug name, and the 
	--number of claims (total_claim_count).
WITH drugs_1 AS (SELECT prescriber.npi, drug.drug_name
				FROM prescriber
				CROSS JOIN drug
				WHERE specialty_description ILIKE 'Pain%' AND (nppes_provider_city = 'NASHVILLE') 
						AND (opioid_drug_flag = 'Y')
				GROUP BY prescriber.npi, drug.drug_name
				ORDER BY prescriber.npi)
SELECT npi, drugs_1.drug_name, SUM(total_claim_count) AS total_claim_count
FROM drugs_1 LEFT JOIN prescription USING(npi, drug_name)
GROUP BY drugs_1.npi, drugs_1.drug_name
ORDER BY npi;
	
    --c. Finally, if you have not done so already, fill in any missing values for total_claim_count with
	--0. Hint - Google the COALESCE function.
WITH drugs_1 AS (SELECT prescriber.npi, drug.drug_name
				FROM prescriber
				CROSS JOIN drug
				WHERE specialty_description ILIKE 'Pain%' AND (nppes_provider_city = 'NASHVILLE') 
						AND (opioid_drug_flag = 'Y')
				GROUP BY prescriber.npi, drug.drug_name
				ORDER BY prescriber.npi)
SELECT npi, drugs_1.drug_name, COALESCE(SUM(total_claim_count),0) AS total_claim_count
FROM drugs_1 LEFT JOIN prescription USING(npi, drug_name)
GROUP BY drugs_1.npi, drugs_1.drug_name
ORDER BY npi;	
