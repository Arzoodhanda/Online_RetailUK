# Load required libraries
library(dplyr)
library(lubridate)
library(ggplot2)
library(cluster)
library(caret)
library(rpart)
library(rpart.plot)
library(tidyr)

# 1. Data Loading & Cleaning ----------------------------------------------
data <- read.csv("online_retail_II.csv", stringsAsFactors = FALSE) %>% 
  filter(
    !is.na(Customer.ID),
    Quantity > 0,
    Price > 0
  ) %>%
  mutate(
    InvoiceDate = as.Date(InvoiceDate, tryFormats = c("%d-%m-%Y", "%Y-%m-%d")),
    TotalSpend = Quantity * Price
  )

# 2. RFM Calculation ------------------------------------------------------
snapshot_date <- max(data$InvoiceDate, na.rm = TRUE) + days(1)

rfm <- data %>%
  group_by(Customer.ID) %>%
  summarise(
    Recency = as.numeric(difftime(snapshot_date, max(InvoiceDate, na.rm = TRUE), units = "days")),
    Frequency = n_distinct(Invoice),
    Monetary = sum(TotalSpend)
  ) %>%
  ungroup()

# Check for missing values
if (any(is.na(rfm))) stop("Missing values detected in RFM data.")

# 3. Clustering ----------------------------------------------------------
# Scale data
rfm_scaled <- rfm %>% 
  select(-Customer.ID) %>% 
  scale() %>% 
  as.data.frame()

# Optimal K selection using Elbow Method
wss <- sapply(1:10, function(k) kmeans(rfm_scaled, centers = k, nstart = 25)$tot.withinss)

plot(1:10, wss, type = "b", pch = 19, frame = FALSE,
     xlab = "Number of Clusters (K)", ylab = "Total Within-Cluster Sum of Squares",
     main = "Elbow Method for Optimal K")

# K-means clustering
set.seed(42)
optimal_k <- 4  # Adjust based on elbow method results
kmeans_model <- kmeans(rfm_scaled, centers = optimal_k, nstart = 25)
rfm$Cluster <- as.factor(kmeans_model$cluster)

# 4. Classification Setup ------------------------------------------------
# Train-test split (Ensuring balanced distribution)
set.seed(42)
train_index <- createDataPartition(rfm$Cluster, p = 0.8, list = FALSE)
train_data <- rfm[train_index, ]
test_data <- rfm[-train_index, ]

# Verify all required columns exist
stopifnot(c("Recency", "Frequency", "Monetary", "Cluster") %in% names(train_data))

# 5. KNN Model -----------------------------------------------------------
ctrl <- trainControl(method = "cv", number = 5)

knn_model <- train(
  Cluster ~ Recency + Frequency + Monetary,
  data = train_data,
  method = "knn",
  trControl = ctrl,
  tuneLength = 10,
  preProcess = c("center", "scale")  # Important for KNN
)

# 6. Decision Tree -------------------------------------------------------
tree_model <- rpart(
  Cluster ~ Recency + Frequency + Monetary,
  data = train_data,
  method = "class",
  control = rpart.control(cp = 0.01) # Prevent overfitting
)

# Pruning decision tree (if needed)
printcp(tree_model)
best_cp <- tree_model$cptable[which.min(tree_model$cptable[, "xerror"]), "CP"]
pruned_tree <- prune(tree_model, cp = best_cp)

# 7. Evaluation ----------------------------------------------------------
# KNN predictions
knn_pred <- predict(knn_model, test_data)
knn_cm <- confusionMatrix(knn_pred, test_data$Cluster)

# Tree predictions
tree_pred <- predict(pruned_tree, test_data, type = "class")
tree_cm <- confusionMatrix(tree_pred, test_data$Cluster)

# Print evaluation metrics
print(knn_cm)
print(tree_cm)

# 8. Visualization -------------------------------------------------------
# Cluster profiles visualization
rfm %>%
  pivot_longer(cols = c(Recency, Frequency, Monetary), names_to = "Metric", values_to = "Value") %>%
  ggplot(aes(x = Cluster, y = Value, fill = Cluster)) +
  geom_col(show.legend = FALSE) +
  facet_wrap(~ Metric, scales = "free") +
  theme_minimal() +
  labs(title = "Cluster Profiles by RFM Metrics")

# Decision tree plot
rpart.plot(pruned_tree, box.palette = "Blues", main = "Pruned Decision Tree")
