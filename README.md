# Epi207: Reproducibility in Epidemiologic Research
---------
# Project 2: Low Income and Non-Cigarette Tobacco/Nicotine Product Use Among California Young Adults

## Research Question: 
Among California adults aged 18–29, is low household income (<200% of the federal poverty level) associated with current use of any non-cigarette tobacco or nicotine product, including e-cigarettes?
- Data Used: 2021-2025 CHIS one-year PUFs

## Project Outputs
- Code: Our SAS script stacks the CHIS 2021-2025 adult public use files into a single dataset and constructs pooled survey weights (each cycle's final weight divided by five, plus 400 jackknife replicate weights). It restricts the sample to adults aged 18-29, recodes the exposure (household income <200% vs. >= 200% FPL), the outcome (current use of any non-cigerette tobacco/nicotine product, including e-cigerettes), and covariates, and checks each recode against the original variable. It then produces Table 1 (unweighted n and weighted % overall and by income group) using PROC SURVEYFREQ, and Table 2 (crude and unadjusted odds ratios) using survey-weighted logistic regression in PROC SURVEYLOGISTIC with jackknife variance estimation. 
- Table 1: Characteristics of California adults aged 18–29 by household income relative to the federal poverty level, CHIS 2021–2025
- Table 2: Crude and adjusted odds ratios for the association between low household income and current non-cigarette tobacco/nicotine product use
- DAG: Directed acyclic graph used to identify the adjustment set


# Project 1: Reproducing Published CHIS Findings
Project description: We reproduced findings from the paper "Soda Consumption and Hospital Admissions among Californian Adults with Asthma" (Cisneros et al., 2017). This paper used CHIS data from 2011 and 2012. 

## Project Outputs
After reading the paper, cleaning the data, and implementing the inclusion and exclusion criteria, we reproduced the following Tables: 
- Table 1: Selected characteristics of adult asthmatics in the adult public use file og the 2011-2012 California Health Interview Survey(CHIS)
- Table 2: Associations between consumption of soda and asthma-related overnight hospital admission among California adult asthmatics

## Paper Reproduced
Cisneros R, Gonzalez M, Brown P, Schweizer D. Soda consumption and
hospital admissions among Californian adults with asthma. Journal of
Asthma. 2017 Apr 21;54(4):371-5.


## Created by
* Sofia Valenzuela
* Sathvika Musuvathy
* Rebekah Jung
* Sukrity Ojha

*E-MAIL*

Sofia Valenzuela: sofiavalenzuela@g.ucla.edu
Sathvika Musuvathy: sathvikasm@g.ucla.edu
Rebekah Jung: rebjung@ucla.edu
Sukrity Ohja: sukrityojha@g.ucla.edu
