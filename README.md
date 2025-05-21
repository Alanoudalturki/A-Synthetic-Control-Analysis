# The Impact of SB-482 on Benzodiazepine Prescribing in California: A Synthetic Control Analysis

## Overview

This project investigates the impact of California’s Senate Bill 482 (SB-482), implemented in 2018, which mandates prescribers to consult the state’s Prescription Drug Monitoring Program (PDMP) prior to prescribing controlled substances, including benzodiazepines. Using the Synthetic Control Method (SCM), the study estimates the causal effect of this policy on benzodiazepine prescribing trends in California, compared to a weighted combination of control states.

## Type of Analysis

**Causal Inference – Synthetic Control Method (SCM)**  
- Created a synthetic version of California from non-intervention states to estimate counterfactual outcomes  
- Compared actual prescribing trends with the synthetic control to isolate the policy's effect  
- Visualized divergence post-policy to assess potential causal impact

---

## Research Question

Did the implementation of SB-482 in California in 2018 lead to a significant reduction in benzodiazepine prescribing compared to other states?

---

## Data Description

- **Source**: Medicare Part D Prescriber Public Use File (CMS)
- **Time Period**: 2017–2022
- **Unit of Analysis**: U.S. states (state-year level)
- **Outcome Variable**: `claims_per_1000` — benzodiazepine prescriptions per 1,000 Medicare beneficiaries
- **Treatment Unit**: California (SB-482 enacted in 2018)
- **Control Group**: Synthetic California (constructed using weighted average of other U.S. states)

---

## Methodology

1. **Preprocessing**
   - Filtered out states with incomplete 6-year data
   - Constructed treated unit (California) and donor pool

2. **Synthetic Control Construction**
   - Applied `Synth` R package for SCM implementation
   - Used 2017–2018 as the pre-policy training window
   - Generated weights to create a synthetic control closely matching California’s pre-intervention trend

3. **Visualization**
   - Plotted California vs. Synthetic California over time (2017–2022)
   - Calculated and visualized gaps between actual and counterfactual outcomes

---

## Results

- **Aggregate Trend Comparison**: California’s prescribing increased post-policy, diverging from national trends  
- **SCM Result**: A clear gap between California and its synthetic counterpart emerged post-2018, particularly during 2020  
- **2020–2022**: A delayed decline in prescribing was observed, but California remained above the synthetic control

---

## Interpretation

- **Initial Increase**: Possible delayed enforcement, increased anxiety during COVID-19, or limited compliance  
- **Later Decline**: May reflect gradual PDMP integration, national guidelines, or pandemic-related prescribing shifts  
- **Conclusion**: SB-482 may not have had immediate impact but was followed by a delayed prescribing decline

---

## Limitations

- Limited pre-policy data (only two years for matching)  
- No adjustment for confounders such as COVID-19 burden or demographic shifts  
- Focused on aggregate prescription rates without clinical detail

---

## Tools & Technologies

- R (`Synth` package)  
- Data visualization and SCM diagnostics  
- Public health policy analysis and causal inference framework

---

## Skills Demonstrated

- Causal inference using synthetic control methods  
- Policy evaluation with observational data  
- Health services research  
- Data visualization and temporal trend interpretation

---

## Author

**Alanoud Alturki**  
Health Data Analyst | Health Informatics Specialist | Pharmacist  
MS in Health Informatics · MS in Health Data Analysis · PhD Student  
[LinkedIn](https://www.linkedin.com/in/alanoud-alturki-5601b2b5)

---

## License

This project is intended for educational and research purposes only. Data used is publicly available and de-identified. Please cite this project appropriately if referenced in academic work.
