# Load required libraries
library(Synth)
library(tidyverse)

# Step 1: Load and clean the dataset
df <- read_csv("benzo_state_year_summary.csv") %>%
  rename(outcome = claims_per_1000) %>%
  filter(year %in% 2017:2022) %>%
  filter(!state %in% c("AE", "AP"))

# Step 2: Keep only states with complete data (6 years)
df <- df %>%
  group_by(state) %>%
  filter(n() == 6) %>%
  ungroup()

# Step 3: Assign numeric unit IDs and clean missing data
df <- df %>%
  mutate(unit.num = as.numeric(as.factor(state))) %>%
  filter(!is.na(outcome), !is.infinite(outcome)) %>%
  select(unit.num, state, year, outcome)

# Step 4: Identify treated and control units
treated_id <- df$unit.num[df$state == "CA"][1]
control_ids <- unique(df$unit.num[df$state != "CA"])

# Step 5: Convert to base R data.frame
df <- as.data.frame(df)

# Step 6: Prepare data for Synth
dataprep_out <- dataprep(
  foo = df,
  predictors = NULL,
  special.predictors = list(
    list("outcome", 2017, "mean"),
    list("outcome", 2018, "mean")
  ),
  dependent = "outcome",
  unit.variable = "unit.num",
  time.variable = "year",
  treatment.identifier = treated_id,
  controls.identifier = control_ids,
  time.predictors.prior = 2017:2018,
  time.optimize.ssr = 2017:2018,
  time.plot = 2017:2022
)

# Step 7: Fit the synthetic control model
synth_out <- synth(dataprep_out)

# Step 8: Plot Synth results
path.plot(
  synth_out,
  dataprep_out,
  Main = "Synthetic Control: Benzo Prescribing in California",
  Ylab = "Claims per 1,000 beneficiaries",
  Xlab = "Year",
  Legend = c("California", "Synthetic California"),
  Legend.position = "bottomright"
)

# Step 9: Calculate changes pre vs post policy
df_change <- df %>%
  group_by(state) %>%
  summarise(
    pre2018 = mean(outcome[year %in% c(2017, 2018)]),
    post2018 = mean(outcome[year %in% 2019:2022]),
    change = post2018 - pre2018
  ) %>%
  arrange(desc(change))

# Step 10: Plot change by state
ggplot(df_change, aes(x = reorder(state, change), y = change, fill = state == "CA")) +
  geom_col() +
  coord_flip() +
  labs(
    title = "Change in Benzo Prescribing After 2018 (Post - Pre)",
    y = "Change in Claims per 1,000",
    x = "State"
  ) +
  scale_fill_manual(values = c("gray", "red")) +
  theme_minimal()

# Step 11: Custom Plot of actual vs synthetic for California
year_seq <- dataprep_out$tag$time.plot
Y1 <- dataprep_out$Y1plot
Y_synth <- dataprep_out$Y0plot %*% synth_out$solution.w

plot_df <- data.frame(
  year = year_seq,
  California = as.numeric(Y1),
  Synthetic_CA = as.numeric(Y_synth)
) %>%
  pivot_longer(cols = c("California", "Synthetic_CA"), names_to = "Group", values_to = "Outcome")

# Plot it
ggplot(plot_df, aes(x = year, y = Outcome, color = Group)) +
  geom_line(size = 1.2) +
  geom_vline(xintercept = 2018, linetype = "dashed", color = "black", size = 1) +
  labs(
    title = "Synthetic Control: Benzo Prescribing in California",
    subtitle = "Dashed line marks policy introduction in 2018",
    x = "Year",
    y = "Claims per 1,000 beneficiaries"
  ) +
  scale_color_manual(values = c("California" = "red", "Synthetic_CA" = "blue")) +
  theme_minimal(base_size = 14) +
  theme(
    legend.title = element_blank(),
    legend.position = "bottom"
  )

# Step 12: Aggregate average comparison plot
df_avg <- df %>%
  mutate(group = if_else(state == "CA", "California", "Other States")) %>%
  group_by(year, group) %>%
  summarise(avg_claims = mean(outcome, na.rm = TRUE), .groups = "drop")

ggplot(df_avg, aes(x = year, y = avg_claims, color = group)) +
  geom_line(size = 1.5) +
  geom_point(size = 3) +
  geom_vline(xintercept = 2018, linetype = "dashed", color = "navy", linewidth = 1.2) +
  labs(
    title = "Impact of SB-482 Policy on Benzodiazepine Prescribing in California",
    subtitle = "Comparison of Average Claims per 1,000 Beneficiaries (2017–2022)",
    x = "Year",
    y = "Benzo Claims per 1,000 Beneficiaries",
    color = "Group"
  ) +
  scale_color_manual(values = c("California" = "#E63946", "Other States" = "#457B9D")) +
  theme_minimal(base_size = 12) +
  theme(
    plot.title = element_text(face = "bold"),
    legend.title = element_blank(),
    legend.position = "top"
  )
#-------------------------------------------------------------------


# Extract actual and synthetic outcomes
year_seq <- dataprep_out$tag$time.plot
Y1 <- dataprep_out$Y1plot  # Treated (California)
Y_synth <- dataprep_out$Y0plot %*% synth_out$solution.w  # Synthetic CA

# Create a tidy dataframe for ggplot
plot_df <- data.frame(
  Year = year_seq,
  California = as.numeric(Y1),
  Synthetic_CA = as.numeric(Y_synth)
) %>%
  pivot_longer(cols = c("California", "Synthetic_CA"),
               names_to = "Group", values_to = "Claims")

# 📈 Plot using ggplot2
library(ggplot2)

ggplot(plot_df, aes(x = Year, y = Claims, color = Group, linetype = Group)) +
  geom_line(size = 1.5) +
  geom_vline(xintercept = 2018, linetype = "dashed", color = "black", size = 1) +
  scale_color_manual(values = c("California" = "#E63946", "Synthetic_CA" = "#457B9D")) +
  scale_linetype_manual(values = c("California" = "solid", "Synthetic_CA" = "dashed")) +
  labs(
    title = "Synthetic Control: Impact of SB-482 in California",
    subtitle = "Dashed line marks policy introduction (2018)",
    x = "Year",
    y = "Claims per 1,000 beneficiaries",
    color = "Group",
    linetype = "Group"
  ) +
  theme_minimal(base_size = 14) +
  theme(
    plot.title = element_text(face = "bold"),
    legend.position = "bottom"
  )

