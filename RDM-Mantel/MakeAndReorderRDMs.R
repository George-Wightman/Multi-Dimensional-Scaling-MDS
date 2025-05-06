library(readr)
library(tidyverse)
library(ggplot2)
library(reshape2)
library(dplyr)


####Reordering the matrix 

  # Function to reorder the matrix based on a given dimension
    reorder_matrix <- function(matrix, rankings, dimension) {
      # Sort the stimuli based on the given dimension
      ordered_stimuli <- rankings %>%
        arrange(get(dimension)) %>%
        pull(Name)
      
      # Reorder the matrix
      matrix <- matrix[ordered_stimuli, ordered_stimuli]
      
      # Remove the diagonal 0s by setting them to NA
      diag(matrix) <- NA
      
      return(matrix)
    }
  
    # Reorder based on Formidable
    formidable_matrix <- reorder_matrix(dissimilarity_matrix, stimuli_labels, "Formidable")
    # Reorder based on Friendly
    friendly_matrix <- reorder_matrix(dissimilarity_matrix, stimuli_labels, "Friendly")
    # Reorder based on Planned
    planned_matrix <- reorder_matrix(dissimilarity_matrix, stimuli_labels, "Planned")
    # Reorder based on Abducting
    abducting_matrix <- reorder_matrix(dissimilarity_matrix, stimuli_labels, "Abducting")
    
  
### Define global min and max dissimilarity values based on the min and max of all 4 data sets
  global_min <- 0.56  # The minimum value across all datasets
  global_max <- 7.73  # The maximum value across all datasets

  global_min <- 0  # The minimum value across all datasets
  global_max <- 1  # The maximum value across all datasets
  
  #Old looks for min max of the current dataset
  global_min <- min(c(formidable_matrix, friendly_matrix, planned_matrix, abducting_matrix), na.rm = TRUE)
  global_max <- max(c(formidable_matrix, friendly_matrix, planned_matrix, abducting_matrix), na.rm = TRUE)
  
  
#### Normalisation
  # Custom function to normalize a matrix to a fixed range
    normalize_matrix <- function(matrix, global_min, global_max) {
      matrix_range <- range(matrix, na.rm = TRUE)
      matrix <- (matrix - matrix_range[1]) / (matrix_range[2] - matrix_range[1]) * (global_max - global_min) + global_min
      return(matrix)
  }
  
  # Normalize matrices
    formidable_matrix <- normalize_matrix(formidable_matrix, global_min, global_max)
    friendly_matrix <- normalize_matrix(friendly_matrix, global_min, global_max)
    planned_matrix <- normalize_matrix(planned_matrix, global_min, global_max)
    abducting_matrix <- normalize_matrix(abducting_matrix, global_min, global_max)
  
    
    
#### Make RDMs Pretty
  # Function to melt data, plot it, and save the plot
    create_heatmap <- function(matrix_data, output_filename, title, global_min, global_max) {
      # Prepare the data for plotting
      melted_matrix <- melt(matrix_data, varnames = c("stim1", "stim2"), value.name = "dissimilarity")
      
      # Plot the heatmap
      p <- ggplot(data = melted_matrix, aes(x = stim1, y = stim2, fill = dissimilarity)) +
        geom_tile() +
        scale_fill_gradient2(low = "blue", mid = "white", high = "red", midpoint = (global_min + global_max) / 2, limits = c(global_min, global_max)) +
        theme_minimal() +
        theme(
          axis.text.x = element_text(angle = 90, vjust = 0.5, hjust = 1, size = 12, face = "bold"),
          axis.text.y = element_text(size = 12, face = "bold"),
          axis.title.x = element_text(size = 14, face = "bold"),
          axis.title.y = element_text(size = 14, face = "bold"),
          plot.title = element_text(size = 16, face = "bold")
        ) +
        labs(title = title, x = "Stimuli", y = "Stimuli", fill = "Dissimilarity")
      
      # Save the plot
      ggsave(output_filename, plot = p, width = 10, height = 8)
    }

  
  
#### Save RDMs
  setwd("H:\\My Drive\\Nicks Work\\MDS\\A- RDMs\\Save Location")

  setwd("H:\\My Drive\\Nicks Work\\MDS\\A- RDMs\\test")
    
  #Raw
    create_heatmap(formidable_matrix, "1RawSimilarity_formidable_heatmap.png", "Formidable Matrix", global_min, global_max)
    create_heatmap(friendly_matrix, "2RawSimilarity_friendly_heatmap.png", "Friendly Matrix", global_min, global_max)
    create_heatmap(planned_matrix, "3RawSimilarity_planned_heatmap.png", "Planned Matrix", global_min, global_max)
    create_heatmap(abducting_matrix, "4RawSimilarity_abducting_heatmap.png", "Abducting Matrix", global_min, global_max)
  
  #Abducting
    create_heatmap(formidable_matrix, "1Abducting_formidable_heatmap.png", "Formidable Matrix", global_min, global_max)
    create_heatmap(friendly_matrix, "2Abducting_friendly_heatmap.png", "Friendly Matrix", global_min, global_max)
    create_heatmap(planned_matrix, "3Abducting_planned_heatmap.png", "Planned Matrix", global_min, global_max)
    create_heatmap(abducting_matrix, "4Abducting_abducting_heatmap.png", "Abducting Matrix", global_min, global_max)
  
  #Formidable
    create_heatmap(formidable_matrix, "1Formidable_formidable_heatmap.png", "Formidable Matrix", global_min, global_max)
    create_heatmap(friendly_matrix, "2Formidable_friendly_heatmap.png", "Friendly Matrix", global_min, global_max)
    create_heatmap(planned_matrix, "3Formidable_planned_heatmap.png", "Planned Matrix", global_min, global_max)
    create_heatmap(abducting_matrix, "4Formidable_abducting_heatmap.png", "Abducting Matrix", global_min, global_max)
  
  #Friendliness 
    create_heatmap(formidable_matrix, "1Friendliness_formidable_heatmap.png", "Formidable Matrix", global_min, global_max)
    create_heatmap(friendly_matrix, "2Friendliness_friendly_heatmap.png", "Friendly Matrix", global_min, global_max)
    create_heatmap(planned_matrix, "3Friendliness_planned_heatmap.png", "Planned Matrix", global_min, global_max)
    create_heatmap(abducting_matrix, "4Friendliness_abducting_heatmap.png", "Abducting Matrix", global_min, global_max)
  
  #Planned
    create_heatmap(formidable_matrix, "1Planned_formidable_heatmap.png", "Formidable Matrix", global_min, global_max)
    create_heatmap(friendly_matrix, "2Planned_friendly_heatmap.png", "Friendly Matrix", global_min, global_max)
    create_heatmap(planned_matrix, "3Planned_planned_heatmap.png", "Planned Matrix", global_min, global_max)
    create_heatmap(abducting_matrix, "4Planned_abducting_heatmap.png", "Abducting Matrix", global_min, global_max)

  
# Save the reordered matrices to CSV files
  write.csv(formidable_matrix, "formidable_matrix.csv", row.names = TRUE)
  write.csv(friendly_matrix, "friendly_matrix.csv", row.names = TRUE)
  write.csv(planned_matrix, "planned_matrix.csv", row.names = TRUE)
  write.csv(abducting_matrix, "abducting_matrix.csv", row.names = TRUE)
  
  
  
