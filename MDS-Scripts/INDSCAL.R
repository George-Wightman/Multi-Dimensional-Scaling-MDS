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
  


##### Data formatting and relabeling ############
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
  

  
#### Performing INDSCAL #######
  n_dimensions <- 2
  indscal_result <- indscal(individual_dissimilarity_matrices, ndim = n_dimensions, type = "ordinal", itmax = 20000 )
  
  
  print(indscal_result)
  print(indscal_result$stress)


####Wait Till its done ####
  #Saves the Gspace for each action
  write.csv(indscal_result$gspace, "Set_INDSCAL_D_gspace.csv")


  
####Extracting the cweight for n_dimensions number of dimensions per participant and saving as a CSV#####

    # Initialize an empty data frame to store the ratios
    # The column names are dynamically created based on the number of dimensions
    num_dimensions <- dim(indscal_result$cweights[[1]])[1]  # Assuming all cweights matrices are square
    col_names <- c("ParticipantID", paste0("Dim", 1:num_dimensions, "_cweight"))
    dim_ratios_df <- data.frame(matrix(ncol = length(col_names), nrow = 0))
    colnames(dim_ratios_df) <- col_names
    
    # Loop through each participant to extract dimension ratios
    for (i in seq_along(indscal_result$cweights)) {
      
      # Extract the diagonal elements for dimension ratios
      dim_ratios <- diag(indscal_result$cweights[[i]])
      
      # Get the participant ID from the names of the individual_dissimilarity_matrices list
      participant_id <- names(individual_dissimilarity_matrices)[i]
      
      # Create a temporary data frame to hold the current participant's data
      temp_df <- data.frame(ParticipantID = participant_id, t(dim_ratios))
      colnames(temp_df) <- col_names
      
      # Append to the main data frame
      dim_ratios_df <- rbind(dim_ratios_df, temp_df)
    }
    
    # Save the data frame to a CSV file
    write.csv(dim_ratios_df, "Set_INDSCAL_D_cweights.csv", row.names = FALSE)
    
    
    
#### Full labels, INDSCAL Common Space plot 
    common_space_df <- as.data.frame(indscal_result$conf)
    colnames(common_space_df) <- c("Dim1", "Dim2")
    common_space_df$Action <- unique_stimuli  # or whatever you have as labels for the stimuli
    
    # Get the range for the dimensions
    x_range <- range(common_space_df$Dim1)
    y_range <- range(common_space_df$Dim2)
    
    # Calculate the new limits
    x_limits <- c(x_range[1] - 0.3, x_range[2] + 0.3)
    y_limits <- c(y_range[1] - 0.3, y_range[2] + 0.3)
    
    # Plot with updated axis limits, no color coding or legend
    ggplot(common_space_df, aes(x = Dim1, y = Dim2, label = Action)) +
      geom_point(size = 4) +
      geom_text(nudge_y = 0.05, nudge_x = 0.05) +
      xlim(x_limits) +
      ylim(y_limits) +
      labs(
        title = "INDSCAL Common Space Configuration",
        x = "Dimension 1",
        y = "Dimension 2"
      ) +
      theme_minimal() 
    


    
    

