library(readr)
library(ggplot2)
library(tidyverse)
library(vegan)


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
####Data formattig and labelling 

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
  
  
  
  
  
###### MetaMDS Per Participant ############
  # Define the number of dimensions
  num_dimensions <- 2
  
##Start Analysis
  # Create dynamic column names for the coordinates based on the number of dimensions
  coordinate_column_names <- paste0("Dim", 1:num_dimensions)
  
  # Initialize an empty data frame with dynamic coordinate columns for metaMDS
  final_results_metaMDS <- data.frame(Participant_ID = character(),
                                      Action = character(),
                                      Stress = numeric(),
                                      stringsAsFactors = FALSE)
  
  # Add coordinate columns dynamically for metaMDS
  for (dim_name in coordinate_column_names) {
    final_results_metaMDS[[dim_name]] <- numeric()
  }
  
  # Run metaMDS and store results
  for (participant_id in names(individual_dissimilarity_matrices)) {
    diss_matrix <- individual_dissimilarity_matrices[[participant_id]]
    
    # Run the metaMDS function with 'k' parameter for the number of dimensions
    metaMDS_result <- metaMDS(diss_matrix, k = num_dimensions)
    
    actions <- rownames(metaMDS_result$points)  # Assuming actions are row names of the points matrix
    
    for (i in 1:nrow(metaMDS_result$points)) {
      # Create a new row with all data for this participant and action
      new_row <- setNames(as.list(c(Participant_ID = participant_id,
                                    Action = actions[i],
                                    Stress = metaMDS_result$stress,
                                    metaMDS_result$points[i, ])), 
                          c("Participant_ID", "Action", "Stress", coordinate_column_names))
      
      # Bind this row to the final_results_metaMDS dataframe
      final_results_metaMDS <- rbind(final_results_metaMDS, new_row)
    }
  }
  
  # Write the metaMDS data to a new CSV file
  write.csv(final_results_metaMDS, "Set_D_metaMDS_PerP.csv", row.names = FALSE)
  
  
  
  
  
  
  
  
  
  
######################## Notes ###########################
  
  #Get eroor warning that there may be insufficient data as stress is nearly 0
  #It still works however
  
  "Warning messages:
    1: In metaMDS(diss_matrix, k = num_dimensions) :
    stress is (nearly) zero: you may have insufficient data
  2: In metaMDS(diss_matrix, k = num_dimensions) :
    stress is (nearly) zero: you may have insufficient data
  3: In metaMDS(diss_matrix, k = num_dimensions) :
    stress is (nearly) zero: you may have insufficient data
  4: In metaMDS(diss_matrix, k = num_dimensions) :
    stress is (nearly) zero: you may have insufficient data"
  
  #I think this is because metaMDS is necessarily designed for our kind of data, its mainly for ecological research
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
