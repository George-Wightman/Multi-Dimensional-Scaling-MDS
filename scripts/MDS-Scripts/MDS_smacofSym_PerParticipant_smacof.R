library(readr)
library(ggplot2)
library(tidyverse)
library(smacof)


############# FOR SET 1 ##########
  #Set Working Directory
  setwd("H:\\My Drive\\Nicks Work\\MDS\\Set1_Data")
  #Load Raw data, contains demographic information as well, each participant has a row, column 5 onwayds is similarity data
  raw_similarity_data <- read.csv("SmallMDS_Set1_CSV.csv")
  #Load the action name labels 
  stimuli_labels <- read.csv("SmallMDS_Set1_stimuli.csv")
  #Isolate the rating data
  similarity_data <- as.matrix(raw_similarity_data[, 5:ncol(raw_similarity_data)])
  dissimilarity_data <- as.matrix(9 - raw_similarity_data[, 5:ncol(raw_similarity_data)])

############## FOR SET 2 ########
  #Set Working Directory
  setwd("H:\\My Drive\\Nicks Work\\MDS\\Set2_Data")
  #Load Raw data, contains demographic information as well, each participant has a row, column 5 onwayds is similarity data
  raw_similarity_data <- read.csv("SmallMDS_Set2_Summary_CSV.csv")
  #Load the action name labels 
  stimuli_labels <- read.csv("SmallMDS_Set2_stimuli_CSV.csv")
  similarity_data <- as.matrix(raw_similarity_data[ , 10:ncol(raw_similarity_data)]) 
  dissimilarity_data <- as.matrix( 9 - raw_similarity_data[ , 10:ncol(raw_similarity_data)])



######### INDIVIDUAL DISSIMILARITY MATRICIES LIST ########
####Data formatting and labeling 

  #Create a stimuli_mapping as you did
  stimuli_mapping <- setNames(stimuli_labels$Name, stimuli_labels$Actions)
  names(stimuli_mapping) <- sprintf("%03d", as.integer(names(stimuli_mapping)))
  
  #Extracting Participant ID from Set
  participant_ids <- raw_similarity_data[, 1] 
  
  ##Creating the lsit of dissimilarity matricies per participant 
  # Initialize a list to store individual dissimilarity matrices
  individual_dissimilarity_matrices <- list()
  
  # Loop through each participant to create dissimilarity matrices
  for (participant in 1:nrow(dissimilarity_data)) {
    
    # Extract data for the current participant
    participant_data <- dissimilarity_data[participant, ]
    
    # Remove 'X' prefix and split the column names to get stimulus pairs
    stimuli_pairs <- gsub("X", "", colnames(dissimilarity_data))
    stim1 <- sapply(strsplit(stimuli_pairs, "\\."), "[", 1)
    stim2 <- sapply(strsplit(stimuli_pairs, "\\."), "[", 2)
    
    # Convert stim1 and stim2 to character vectors if they aren't already
    stim1 <- as.character(stim1)
    stim2 <- as.character(stim2)
    
    # Replace stimulus numbers with names
    stim1 <- stimuli_mapping[stim1]
    stim2 <- stimuli_mapping[stim2]
    
    # Remove NA values if any (in case some stimulus numbers couldn't be mapped)
    valid_indices <- !is.na(stim1) & !is.na(stim2)
    stim1 <- stim1[valid_indices]
    stim2 <- stim2[valid_indices]
    
    # Get unique stimuli and initialize dissimilarity matrix
    unique_stimuli <- unique(c(stim1, stim2))
    n_stimuli <- length(unique_stimuli)
    dissimilarity_matrix <- matrix(0, nrow = n_stimuli, ncol = n_stimuli,
                                   dimnames = list(unique_stimuli, unique_stimuli))
    
    # Populate dissimilarity matrix
    for (i in seq_along(stim1)) {
      row_index <- which(unique_stimuli == stim1[i])
      col_index <- which(unique_stimuli == stim2[i])
      dissimilarity_matrix[row_index, col_index] <- participant_data[i]
      dissimilarity_matrix[col_index, row_index] <- participant_data[i]  # Symmetric
    }
    
    # Add the matrix to the list
    individual_dissimilarity_matrices[[participant]] <- dissimilarity_matrix
    names(individual_dissimilarity_matrices)[participant] <- participant_ids[participant]
  }
  
 
  
  
  
##### SmacofSym Per Participant #######
  # Define the number of dimensions
  num_dimensions <- 2
  
  
##Start Analysis
  # Initiating List
  results_list <- list()
  
  for (participant_id in names(individual_dissimilarity_matrices)) {
    diss_matrix <- individual_dissimilarity_matrices[[participant_id]]
    
    # Run the smacofSym function with the 'ndim' parameter for the number of dimensions
    smacof_result <- smacofSym(diss_matrix, type = "ordinal", ndim = num_dimensions)  
    
    # Store the Coordinates and stress for each participant in results_list
    results_list[[participant_id]] <- list(
      coordinates = smacof_result$conf,
      stress = smacof_result$stress
    )
  }
  
  
##Extract and Store Results
  
  # Create dynamic column names for coordinates based on the number of dimensions
  coordinate_column_names <- paste0("Dim", 1:num_dimensions)
  
  # Initialize an empty data frame with dynamic coordinate columns
  final_results <- data.frame(Participant_ID = character(),
                              Action = character(),
                              Stress = numeric(),
                              stringsAsFactors = FALSE)
  
  # Add coordinate columns dynamically
  for (dim_name in coordinate_column_names) {
    final_results[[dim_name]] <- numeric()
  }
  
  # Populate the data frame
  for (participant_id in names(results_list)) {
    participant_results <- results_list[[participant_id]]
    actions <- rownames(participant_results$coordinates)  # Assuming actions are row names
    
    for (i in 1:nrow(participant_results$coordinates)) {
      # Create a new row with all data for this participant and action
      new_row <- setNames(as.list(c(Participant_ID = participant_id,
                                    Action = actions[i],
                                    Stress = participant_results$stress,
                                    participant_results$coordinates[i, ])), 
                          c("Participant_ID", "Action", "Stress", coordinate_column_names))
      
      # Bind this row to the final_results dataframe
      final_results <- rbind(final_results, new_row)
    }
  }
  
  # Write the results data to a new CSV file
  write.csv(final_results, "Set_D_smacof_PerP.csv", row.names = FALSE)
  

    
  
  
  
  
  
  
  
  
  
  
  library(readr)
  library(tidyverse)
  
  
  
  
  library(readr)
  library(tidyverse)
  library(broom) # for tidy summary of regression results
  
  # Step 1: Read in the models' scores for each action
  model_scores <- stimuli_labels[, c(3, 12:19)]
  
  # Step 2: Assuming `results_list` is already populated with MDS coordinates
  # Retrieve the coordinates for one participant, let's say the first one in the list
  participant_id <- names(results_list)[1] # replace with a specific participant ID if needed
  coordinates <- results_list[[participant_id]]$coordinates
  
  # Convert the coordinates to a data frame for easier manipulation
  coordinates_df <- as.data.frame(coordinates)
  
  # Add action names as a new column in the coordinates data frame
  coordinates_df$Action <- rownames(coordinates)
  
  # Step 3: Merge the model scores with the coordinates data frame
  # Make sure that the 'Name' column in model_scores matches the actions in coordinates_df
  regression_data <- merge(coordinates_df, model_scores, by.x = "Action", by.y = "Name")
  
  
  
  
  
  # Step 4: Perform multivariate regression for each action
  # Initialize a list to store regression summaries
  regression_summaries <- list()
  
  # Loop over each action in the regression data
  for (action in unique(regression_data$Action)) {
    # Subset the data for the current action
    action_data <- subset(regression_data, Action == action)
    
    # Perform the multivariate regression using the lm function
    reg_model <- lm(cbind(D1, D2) ~ Formidable + Friendly + Planned + Abducting + ChangeModel + SocialityModel + TransitivityModel + FulfilmentModel, data = action_data)
    
    # Store the tidy summary of the regression results using broom::tidy
    # broom::tidy() automatically splits the multivariate regression results by response variable
    regression_summaries[[action]] <- broom::tidy(reg_model)
  }
  
  # Print the regression summaries for a specific action
  # This will show the regression results for both D1 and D2
  print(regression_summaries[["aching(back)"]]) # replace with the actual action name
  
  
  
  
  
  
  
  
  
  
  
  
  
