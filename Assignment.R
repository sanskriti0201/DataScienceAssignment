#load necessary libraries
library(ggplot2)
library(reshape2)
library(corrplot)
library(ggpubr)
library(rlang)
library(MASS)         # For regression diagnostics
library(car)          # For Q-Q plots
library(caret)        # For train-test split
library(lattice)
library(MASS)         # For matrix calculations if needed


#load the data set
data <- read.csv("Dataset_Assignment.csv")
#Task: Visualizing, Analayzing and Rearranging Data
#since x2 is output signal and rest are input rearranging the data to shift colun x2 to end of dataset
data <- data[, c(setdiff(names(data),"x2"), "x2")] 
#renaming column x2 as output
colnames(data)[5]<-"Output" #since x2 is now in the 5th column
#Viewing the changed data
head(data,10)

#Task 1: Preliminary Data Analysis
#Task 1.1: Summarizing the Data calculating mean, median,standard deviation and variance
summary(data)
std_dev<- apply(data, 2, sd)
  print ("Standard Deviation:")
  print (std_dev)
variance <- apply(data,2,var)
  print("Varience:")
  print(variance)

#Determining missing values using the is.ns function
missing_value <- is.na(data)
missedvalue <- sum(missing_value)
print(sprintf("Number of missing value is %d", missedvalue))

#Task 1.2: PLotting Time Series of Input and Output Data
#Seperating Input and output datas
input_data<- data[,c("x1","x3", "x4","x5")]
output_data<- data$Output

#Plotting Time Series for Input Datas
input_data_ts <- ts(input_data, start = c(0,0),end = c(nrow(input_data)),frequency=1)
plot( input_data_ts,
  main = "Time Series for Input Brain Response to Music",
  xlab= "Time Intervals", 
  col= "blue", 
  lwd = 1) 

#Plotting Time Series for Output Data
output_data_ts <- ts(output_data, start = ,frequency=1)
  plot( output_data_ts,
  main = "Time Series for Output (x2) Brain Response to Music",
  xlab= "Time Intervals",
  ylab = "Output",
  col= "blue", 
  lwd = 1.5) 


#Task 1.3: Distribution For each signal (Histogram and Density Plot)
  # Histogram Plot using a for loop 
  # Histogram Plot using a for loop
  for (col_name in colnames(data)) {
  data_vector <- data[[col_name]]
  # Formula to return the most frequent value: Mode
  get_mode <- function(x){
    unique_x <- unique(na.omit(x)) # omit missing values but since we have no missing values we could use unique(x) instead
    unique_x[which.max(tabulate(match(x,unique_x)))]
  }
  # Calculate summary statistics mean, median, mode and Standard Deviation
  data_mean <- mean(data_vector, na.rm = TRUE)   # Mean
  data_median <- median(data_vector, na.rm = TRUE) # Median
  data_sd <- sd(data_vector, na.rm = TRUE)       # Standard deviation
  data_mode <-get_mode(data_vector)  #Mode: Alternatively since we already know there are no missing values we could also use *data_mode<- as.numeric(names(which.max(table(data_vector))))*
  # Plot the histogram
  hist(data_vector, 
    main = paste("Histogram with Mean, Median and Mode for",col_name),
    xlab = paste("Brain Activity", col_name),
    col = "lightblue", 
    border = "black", 
    breaks = 25)  # Adjust breaks for bin size
  
  # Add vertical lines for mean and median
  abline(v = data_mean, col = "blue", lwd = 2, lty = 2)   # Mean as dashed blue line
  abline(v = data_median, col = "red", lwd = 2, lty = 3) # Median as dotted red line
  abline(v = data_mode, col="darkgreen", lwd = 2, lty = 4) #mode as dashed and dotted darkgreen line
  # Add a legend
  legend("topright", 
    legend = c(paste("Mean =", round(data_mean, 2)), 
              paste("Median =", round(data_median, 2)),
              paste("Mode =", round(data_mode, 2)),
              paste("Standard Deviation =", round(data_sd,2))), 
            col = c("blue", "red","darkgreen","black" ), 
            lwd = 2, 
            lty=c(2,3,4,0),
            cex = 0.5) 
  #pause between plots
  readline(prompt ="Press [Enter] to see next plot ")
  }


  # Density Plot for Input Datas using a for loop 
  for (col in names(input_data)) {
    plot <- ggplot(data, aes(x = .data[[col]])) +
      geom_density(fill = "lightblue", color = "black", alpha = 0.6) + 
          labs(title = paste("Spread & Concentration of Music Induced Brain Response of", col),
          subtitle = paste("Distribution of Brain Activity Captured in fMRI Images"),
          x = paste("Brain Activity", col), 
          y = "Density") +
    theme_minimal()
  
  print(plot)
  #pause between plots
  readline(prompt ="Press [Enter] to see next plot ")
  }

  #Density Plot of Output Data
  plot2 <- ggplot(data, aes(x = Output)) +
    geom_density(fill = "lightblue", color = "black", alpha = 0.6) + 
      labs(title = "Spread & Concentration of Music Induced Brain Response of Output",
       subtitle = "Distribution of Brain Activity Captured in fMRI Images",
       x = "Brain Activity", 
       y = "Density") +
    theme_minimal()
  print(plot2)


  # Plot Seperate histogram and density for all input signals for comparison
  plot_hist_density <- ggplot(long_input_data, aes(x = Value)) +
  # Histogram with fill (optional)
  geom_histogram(aes(y = ..density.., fill = Signal), alpha = 0.5 ,bins = 30) +
  # Density lines
  geom_density(aes(color = Signal), size = 1.2) + 
  labs(title = "Distribution of Input Signals",
      x = "Brain Response Input Signals",
      y = "Density",
      fill = "Signal",
      color = "Signal") +
  theme_minimal() +
  theme(legend.position = "top") +
  scale_color_manual(values = c("blue", "red", "green", "purple")) +
  scale_fill_manual(values = c("blue", "red", "green", "purple")) +
  facet_wrap(~ Signal, scales = "free")
  print(plot_hist_density)


  # Extract only the output column (Output)
  output_data <- data[, "Output", drop = FALSE]  # Keep Output as a dataframe
  # Plot histogram and density for output signal Output
  output_plot <- ggplot(output_data, aes(x = Output)) +
  # Solid fill histogram for Output
  geom_histogram(aes(y = ..density..), fill = "#FFD700", color = "#DAA520", bins = 30) +
  # Density line for Output
  geom_density(color = "black", size = 1.5) + 
  labs(
    title = "Distribution of (Output)",
    subtitle = "Histogram and Density Line for Output",
    x = "Brain response Output Signals",
    y = "Density"
  ) 
  # Print the distribution plot for output signal 
  print(output_plot)


#Task 1.4: Correlation Plot
  # Scatter plot of correlation of input and output signals
  for (col in names(input_data)) {
  plot_correlation <- 
    ggplot(data, aes_string(x = col, y = 'Output', color = col)) +
    geom_point(show.legend = TRUE) +
    geom_smooth(method = "lm", level = 0.95, color = "blue", aes(color = NULL)) +
    scale_color_gradient(low = "pink", high = "darkred") +
    labs(title = paste("Relationship Between Output Signal &", col),
         subtitle = "Visualising Dependencies between Brain Response to Music Stimuli") +
    xlab(paste("Brain Response of", col)) +
    ylab("Output Signal") +
    stat_cor(aes(color = NULL), p.accuracy = 0.05, r.accuracy = 0.01, method = "pearson")
  
  print(plot_correlation)
  readline(prompt = "Press [Enter] to see next plot ")
  }


#Regression 
# Task 2: Regression - modelling the relationship between signals
  # Extract input and output signals
  x1 <- data$x1
  x3 <- data$x3
  x4 <- data$x4
  x5 <- data$x5
  y  <- data$Output
  # Number of data points
  n <- length(y)


# Task 2.1: Estimate model parameters theta using Least Squares
  # Model 1: y = theta1*X4 + theta2*(X3)^2 + thetabias
  model1 <- cbind(x4, x3^2, 1)  # Design matrix for Model 1
  theta1 <- solve(t(model1) %*% model1) %*% t(model1) %*% y

  # Model 2: y = theta1*X4 + theta2*(X3)^2 + theta3*X5 + thetabias
  model2 <- cbind(x4, x3^2, x5, 1)  # Design matrix for Model 2
  theta2 <- solve(t(model2) %*% model2) %*% t(model2) %*% y

  # Model 3: y = theta1*X3 + theta2*X4 + theta3*(X5)^3 
  model3 <- cbind(x3, x4, x5^3)  # Design matrix for Model 3
  theta3 <- solve(t(model3) %*% model3) %*% t(model3) %*% y

  # Model 4: y = theta1*X4 + theta2*(X3)^2 + theta3*(X5)^3 + thetabias
  model4 <- cbind(x4, x3^2, x5^3, 1)  # Design matrix for Model 4
  theta4 <- solve(t(model4) %*% model4) %*% t(model4) %*% y

  # Model 5: y = theta1*X4 + theta2*(X1)^2 + theta3*(X3)^2 + thetabias
  model5 <- cbind(x4, x1^2, x3^2, 1)  # Design matrix for Model 5
  theta5 <- solve(t(model5) %*% model5) %*% t(model5) %*% y

  # Store thetas for all models
  theta_list <- list(theta1, theta2, theta3, theta4, theta5)
  print(theta_list)


# Task 2.2: Compute residual sum of squares (RSS) for each model
  RSS <- function(X, y, theta) {
    residuals <- y - X %*% theta
    sum(residuals^2)
  }
  RSS_values <- c(
    RSS(model1, y, theta1), 
    RSS(model2, y, theta2), 
    RSS(model3, y, theta3), 
    RSS(model4, y, theta4), 
    RSS(model5, y, theta5)
  )
  print(data.frame(Model = paste0("Model ", 1:5), RSS = RSS_values))


# Task 2.3: Compute the log-likelihood function for each model
  log_likelihood <- function(RSS, n) {
    variance <- RSS / (n - 1)
    log_likelihood_value <- - (n / 2) * log(2 * pi) - (n / 2) * log(variance) - (1 / (2 * variance)) * RSS
    return(log_likelihood_value)
  }
  log_likelihood_values <- sapply(RSS_values, function(rss) log_likelihood(rss, n))
  print(data.frame(Model = paste0("Model ", 1:5), LogLikelihood = log_likelihood_values))


# Task 2.4: Compute the AIC and BIC for each model
  AIC <- function(log_likelihood, k) {
    2 * k - 2 * log_likelihood
  }

  BIC <- function(log_likelihood, k, n) {
    k * log(n) - 2 * log_likelihood
  }

  k_values <- c(3, 4, 3, 4, 4) 
  AIC_values <- mapply(AIC, log_likelihood_values, k_values)
  BIC_values <- mapply(BIC, log_likelihood_values, k_values, MoreArgs = list(n = n))

  results_aic_bic <- data.frame(
    Model = paste0("Model ", 1:5),
    AIC = AIC_values,
    BIC = BIC_values
  )
  print(results_aic_bic)

# Task 2.5: Q-Q plot for residuals  
  par(mfrow = c(2, 3))  # Set up a 2x3 plotting grid

  for (i in 1:5) {
  residuals <- y - get(paste0("model", i)) %*% get(paste0("theta", i))
  qqnorm(residuals, main = paste("Q-Q Plot for Model", i),
         col=rgb(0,0,1,alpha = 0.4 ),
         pch= 16,
         cex=1.2)
  qqline(residuals, col="red", lwd = 2)
  }
  par(mfrow = c(2, 3))  # Reset plotting layout
  for (i in 1:5) {
    residuals <- y - get(paste0("model", i)) %*% get(paste0("theta", i))
  
  # Histogram for the residuals
  hist(residuals, 
       main = paste("Histogram for Model", i), 
       xlab = "Residuals", 
       col = rgb(0, 0, 1, alpha = 0.4), 
       border = "blue", 
       breaks = 10, 
       cex.lab = 1.2, 
       cex.main = 1.4, 
       cex.axis = 1.2, 
       probability = TRUE)  # Set to TRUE to normalize the histogram
  
}
par(mfrow = c(1, 1))  # Reset plotting layout

# Task 2.6: Identify the best model according to AIC and BIC
  results <- data.frame(
    Model = paste0("Model ", 1:5),
    RSS = RSS_values,
    LogLikelihood = log_likelihood_values,
    Variance = RSS_values / (n - 1),
    AIC = AIC_values,
    BIC = BIC_values
)
  print(results)
  best_model_aic <- results$Model[which.min(results$AIC)]
  best_model_bic <- results$Model[which.min(results$BIC)]
  cat("The best model according to AIC is", best_model_aic, "\n")
  cat("The best model according to BIC is", best_model_bic, "\n")

# Task 2.7: Train-test split, model training, and prediction with confidence intervals
  # Task 2.7.1: Spliting output data into 70% training and 30% testing data
    set.seed(123)  # For reproducibility
    train_index <- sample(1:n, size = round(0.7 * n))
    y_train <- y[train_index]
    y_test <- y[-train_index]
  #Spliting best model data into 70% training and 30% testing data
    best_model_index <- which.min(results$AIC)
    X <- get(paste0("model", best_model_index))
    X_train <- X[train_index, ]
    X_test <- X[-train_index, ]

  #Task: 2.7.2: Prediction
    # Train model on training data
    theta_training <- solve(t(X_train) %*% X_train) %*% t(X_train) %*% y_train
    # Predict on test data
    predictions <- X_test %*% theta_training
    rss_testing <- sum((y_test- predictions)^2)
    sprintf("RSS value of Testing Data is: %0.4f", rss_testing)

  #Task: 2.7.3: Statistical Test
    # Run t-test for hypothesis testing
    test_result <- t.test(y_train, mu=700, alternative="two.sided", conf.level=0.95)
    print(test_result)

  #Task: 2.7.4: Calculating confidence interval and ploting training data vs predicted data 
    # Calculate 95% confidence intervals
    residuals_1 <- y_train - X_train %*% theta_training
    variance <- sum(residuals_1^2) / (length(y_train) - 1)
    se <- sqrt(diag(X_test %*% solve(t(X_train) %*% X_train) %*% t(X_test)) * variance)
    upper_bound <- predictions + 1.96 * se
    lower_bound <- predictions - 1.96 * se

    # Plot predictions with error bars
    plot(y_test, type = "p", col = "blue", main = "Prediction with 95% CI", xlab = "Index", ylab = "Prediction")
    arrows(1:length(y_test), lower_bound, 1:length(y_test), upper_bound, angle = 90, code = 3, col = "red")
    points(predictions, col = "green")

    # Subset a few key indices to reduce clutter
    key_indices <- seq(1, length(y_test), length.out = 15)  # Sample evenly spaced points

    # Plot the key points
    plot(y_test[key_indices], type = "p", col = "blue", 
      main = "Prediction with Key Points and 95% CI", xlab = "Index", ylab = "Prediction")
      arrows(1:15, lower_bound[key_indices], 1:15, upper_bound[key_indices], angle = 90, code = 3, col = "red", lwd = 1.5)
      points(predictions[key_indices], col = "green", pch = 19)
    legend("topright", legend = c("Actual", "Predicted", "95% CI"), 
       col = c("blue", "green", "red"), pch = c(1, 19, NA), lty = c(NA, NA, 1), 
       lwd = 2,
       cex = 0.8)

  #Task: 2.7.5: Distribution Plot Of Training and Testing Data
    #Density plot for training and testing data
    plot_density_with_ci <- function(y_data, title, ci_lower = NULL, ci_upper = NULL, color = "blue") {
    
    #Density estimate for y_data
    density_y <- density(y_data)
      
    #Plot the density curve
    plot(density_y, main = title, xlab = "Value", ylab = "Density", col = color, lwd = 2)
      
    #Add confidence interval lines, if provided
      if (!is.null(ci_lower) & !is.null(ci_upper)) {
        abline(v = ci_lower, col = "red", lty = 2, lwd = 2) # Lower bound
        abline(v = ci_upper, col = "red", lty = 2, lwd = 2) # Upper bound
      }
    #Add a vertical line for the mean of the data
    mean_y <- mean(y_data)
    abline(v = mean_y, col = "purple", lty = 1, lwd = 2) # Mean line
    }
    
    #Plot the density for training data with confidence interval
    ci_lower_train <- mean(y_train) - 1.96 * sqrt(variance)
    ci_upper_train <- mean(y_train) + 1.96 * sqrt(variance)
    plot_density_with_ci(y_train, "Density of Training Data with 95% CI", ci_lower_train, ci_upper_train, color = "blue")
    
    #Plot the density for testing predictions with confidence interval
    ci_lower_test <- mean(predictions) - 1.96 * sqrt(variance)
    ci_upper_test <- mean(predictions) + 1.96 * sqrt(variance)
    plot_density_with_ci(predictions, "Density of Testing Data with 95% CI", ci_lower_test, ci_upper_test, color = "green")
    
    # Residuals (prediction errors)
    residuals_test <- y_test - predictions
    # Mean Absolute Error (MAE)
    mae <- mean(abs(residuals_test))
    print(paste("Mean Absolute Error (MAE):", round(mae, 4)))
    # Mean Squared Error (MSE)
    mse <- mean(residuals_test^2)
    print(paste("Mean Squared Error (MSE):", round(mse, 4)))
    # Root Mean Squared Error (RMSE)
    rmse <- sqrt(mse)
    print(paste("Root Mean Squared Error (RMSE):", round(rmse, 4)))
    # R-Squared (R²)
    ss_total <- sum((y_test - mean(y_test))^2)
    ss_residual <- sum(residuals_test^2)
    r_squared <- 1 - (ss_residual / ss_total)
    print(paste("R-squared (R²):", round(r_squared, 4)))

#Task 3:Approximate Bayesian Computation (ABC) using rejection method

  #Task: 3.1: Identify the 2 parameters with the largest absolute values
    param_ranks <- order(abs(theta2), decreasing = TRUE)
    top_2_params <- param_ranks[1:2]  # Indices of the top 2 largest parameters
    theta_fixed <- theta2  # Store the fixed parameters
    theta_fixed[top_2_params] <- NA  # Leave only the 2 largest as "free" (others are fixed)
    
    # Extract the values of the top 2 parameters
    top_2_values <- theta2[top_2_params]

    # Print the top 2 parameters and their values
    cat("Top 2 parameters for ABC:", top_2_params, "\n")
    cat("Values of the top 2 parameters:", top_2_values, "\n")
    cat("Estimated coefficients from least squares (theta2):", theta2, "\n")


# Task:3.2 : Define Priors
  # Define prior ranges for the top 2 parameters
    prior_range <- 0.2  # Range (e.g., ±20% of the least-squares estimates)
    theta_prior <- matrix(0, nrow = 2, ncol = 2)
    for (i in 1:2) {
      param_index <- top_2_params[i]
      theta_prior[i, 1] <- theta2[param_index] * (1 - prior_range)  # Lower bound of uniform prior
      theta_prior[i, 2] <- theta2[param_index] * (1 + prior_range)  # Upper bound of uniform prior
    }

    cat("Prior ranges for top 2 parameters:", theta_prior, "\n")

# Task 3.3: Rejection ABC
  # Hyperparameters
    num_samples <- 5000  # Total number of samples

  # Compute all distances and set epsilon as the 10th percentile of distances
    all_distances <- numeric(num_samples)
    for (i in 1:num_samples) {
    sampled_theta <- runif(2, min = theta_prior[, 1], max = theta_prior[, 2]) ##draws two values randomly from the uniform prior distribution for each of the two largest parameters
    theta_star <- theta_fixed
    theta_star[top_2_params] <- sampled_theta
    y_pred <- model2 %*% theta_star
    all_distances[i] <- sqrt(mean((y - y_pred)^2)) #distance between observed data y and predicted data y_pred is calculated using RMSE (Root Mean Squared Error) and stored in all_distances
    }
    epsilon <- quantile(all_distances, 0.1)  # Set epsilon as 10th percentile of distances
    accepted_params <- matrix(NA, nrow = 0, ncol = 2)  # To store accepted samples

    for (i in 1:num_samples) {
      #Sample from priors for the 2 parameters
      sampled_theta <- runif(2, min = theta_prior[, 1], max = theta_prior[, 2])
  
      #Create a full parameter vector, filling in the sampled parameters
      theta_star <- theta_fixed
      theta_star[top_2_params] <- sampled_theta
  
      #Simulate the model output
      y_pred <- model2 %*% theta_star
  
      #Calculate the distance between predicted and actual data
      distance <- sqrt(mean((y - y_pred)^2))  # Root mean squared error (RMSE)
  
      #Accept the parameter if distance is within epsilon
      if (distance < epsilon) {
      accepted_params <- rbind(accepted_params, sampled_theta)
      }
    }
    cat("Total accepted samples:", nrow(accepted_params), "out of", num_samples, "\n")


#Task 3.4 Plot Joint and Marginal Posterior Distribution
    if (nrow(accepted_params) > 0) {
    par(mfrow = c(1, 2))
  
    # Plot marginal posterior for parameter 1
    hist(accepted_params[, 1], breaks = 15, main = paste("Posterior of theta1-Parameter", top_2_params[1]), xlab = "Value")
  
    # Plot marginal posterior for parameter 2
    hist(accepted_params[, 2], breaks = 15, main = paste("Posterior of theta3-Parameter(theta3)", top_2_params[2]), xlab = "Value")
  
    par(mfrow = c(1, 1))
    # Plot joint posterior distribution (scatterplot)
    plot(accepted_params[, 1], accepted_params[, 2], pch = 20, col = "blue",
       xlab = paste("Parameter", top_2_params[1]), 
       ylab = paste("Parameter", top_2_params[2]), 
       main = "Joint Posterior of Top 2 Parameters")
    }

