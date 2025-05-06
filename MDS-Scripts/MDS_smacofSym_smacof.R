library(readr)
library(ggplot2)
library(tidyverse)
library(smacof)


############# FOR SET 1 ##########
  #Set Working Directory
  setwd("H:\\My Drive\\Nicks Work\\MDS\\Similarity\\Set1_Data")
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



  
  
  
  
  

  
#### DATA FORMATING #####
  ##Average dissimilarity ratings per stimuli pair
  average_dissimilar_data <- colMeans(dissimilarity_data)
  
  ##Changing the action numbers to names
  #Turns average dissimilarity data into data frame. Makes pair groups (004-021) into column not header (means I can use this column in next line)
  average_dissimilar_dataframe <- as.data.frame(colMeans(dissimilarity_data)) %>%
    rownames_to_column(var = "Stimuli")
  
  #Separates the stimuli pairs into separate values (004-021 changes into 004 and 021 separately)
  #It also keeps them as 3 digits (004 not 4) this is required to change into words
  separated_dissimilarity_data <- average_dissimilar_dataframe %>%
    mutate(Stimuli = str_extract(Stimuli, "\\d+\\.\\d+")) %>%
    separate(Stimuli, into = c("stim1", "stim2"), sep = "\\.")
  names(separated_dissimilarity_data)[names(separated_dissimilarity_data)=="colMeans(dissimilarity_data)"] <- "ResponceMeans"
  
  #Linking the number labels to action labels
  stimuli_mapping <- setNames(stimuli_labels$Name, stimuli_labels$Actions)
  names(stimuli_mapping) <- sprintf("%03d", as.integer(names(stimuli_mapping)))
  
  # Changing the labels from Numbers to Names
  separated_dissimilarity_data$stim1 <- stimuli_mapping[as.character(separated_dissimilarity_data$stim1)]
  separated_dissimilarity_data$stim2 <- stimuli_mapping[as.character(separated_dissimilarity_data$stim2)]
  
  ##Creating the Matrix
  
  # Calculate the num of unique stimuli
  unique_stimuli <- unique(c(separated_dissimilarity_data$stim1, separated_dissimilarity_data$stim2))
  n_stimuli <- length(unique_stimuli)
  # Creates a square matrix with the number of unique stimuli as side length
  dissimilarity_matrix <- matrix(0, nrow = n_stimuli, ncol = n_stimuli,
                                 dimnames = list(unique_stimuli, unique_stimuli))
  # Populates the matrix 
  for (i in 1:nrow(separated_dissimilarity_data)) {
    row_index <- which(unique_stimuli == separated_dissimilarity_data$stim1[i])
    col_index <- which(unique_stimuli == separated_dissimilarity_data$stim2[i])
    dissimilarity_matrix[row_index, col_index] <- separated_dissimilarity_data$ResponceMeans[i]
    dissimilarity_matrix[col_index, row_index] <- separated_dissimilarity_data$ResponceMeans[i]}  # If the matrix is symmetric
  
  dissimilarity_matrix<- as.matrix(dissimilarity_matrix)




  
  
  
  
  
  
  
  
##### RUNNING THE MDS ######
  
  ##SMACOF Package MDS and plots
  ##Run nonmetric MDS using smacofSym
  ##Set number of dimensions
  ndims <- 7
  mds_result <- smacofSym(dissimilarity_matrix, ndim = ndims, type = "ordinal")
  
  # Print the result to inspect stress, number of iterations, etc.
  print(mds_result)
  print(paste("Stress value:", mds_result$stress))





  
  
  
  
###### PLOTS #######

##Shepard Diagrams

  #Extract MDS Coordinates
  mds_coordinates <- mds_result$conf
  
  #Calculate Fitted Dissimilarities
  fitted_dissimilarities <- as.vector(dist(mds_coordinates))
  
  #Extract Original Dissimilarities
  original_dissimilarities <- as.vector(as.matrix(dissimilarity_matrix)[upper.tri(dissimilarity_matrix)])
  
  # Create the Shepard diagram
  originals <- as.vector(as.matrix(dissimilarity_matrix)[upper.tri(dissimilarity_matrix)])
  fitted <- fitted_dissimilarities
  
  # Define plot limits
  xlims <- range(c(originals, fitted))
  ylims <- range(c(originals, fitted))
  
  plot(originals, 
       fitted, 
       xlab = "Original Dissimilarities", 
       ylab = "Fitted Dissimilarities", 
       main = "Shepard Diagram",
       xlim = xlims,
       ylim = ylims)
  
  # Add a reference line (y = x)
  abline(a = 0, b = 1, col = "red")
  


##Scree Plot smacofSym
  
  #Plotting a scree plot using Stress and not eigenvalues (eig not given with SmacofSym Ordinal)
  ##Number of dimensions on X
  xdims<- 23
  
  #Initialize a vector to store stress values
  stress_values <- c()
  # The smacofSYM inst giving eigenvalues for some reason, so I'm making a scree-esk diagram comparing stress values
  #Loop over various numbers of dimensions
  for (k in 1:xdims) {
    mds_result_k <- smacofSym(dissimilarity_matrix, ndim = k, type = "ratio")
    stress_values[k] <- mds_result_k$stress
  }
  # Create the plot
  plot(1:xdims, stress_values, type = "b", xlab = "Number of Dimensions", ylab = "Stress Value", main = "Stress Plot")

  
  
## 2D Plots
  
  # Extract the coordinates of items in the MDS space
  mds_coordinates <- mds_result$conf
  # Getting stimuli names 
  stimuli_names <- rownames(mds_coordinates)
  
  # Creating an empty list to export the plots to
  plot_list <- list()
  
  # Loop through each pair of dimensions
  for(i in 1:(ndims - 1)) {
    for(j in (i + 1):ndims) {
      
      # Calculate axis limits
      xlims = range(mds_coordinates[, i]) + c(-0.1, 0.1)  # "Zoom out" by 1 unit
      ylims = range(mds_coordinates[, j]) + c(-0.1, 0.1)  # "Zoom out" by 1 unit
      
      # Generate the plot for dimensions i and j
      plot(mds_coordinates[, i], mds_coordinates[, j], 
           xlab = paste("Dimension", i), 
           ylab = paste("Dimension", j), 
           main = paste("Dimensions", i, "vs", j),
           xlim = xlims, ylim = ylims,  # Set axis limits
           type = "n")  # Create an empty plot
      
      # Add stimuli names to the points
      text(mds_coordinates[, i], mds_coordinates[, j], labels = stimuli_names, cex = 0.7, pos = 3)
      
      # Save the plot in the list
      plot_list[[paste("Dim", i, "vs", "Dim", j)]] <- recordPlot()  # Save the current plot
    }
  }

  
  
  
  
  

  
  
  
  
##### DONT SELECT THIS ######
  
  #Saves the Dissimilarity matrix as a CSV      
  write.csv(dissimilarity_matrix, file = "dissimilarity_matrix.csv")
  
  
  
  ##Export all 2D plots as PNG to working directory
  # Loop through the list of saved plots
  for(i in 1:length(plot_list)) {
    
    # Generate the file name for the i-th plot
    file_name <- paste0("Plot_", names(plot_list)[i], ".png")
    
    # Open a PNG device
    png(filename = file_name, width = 800, height = 600)
    
    # Redraw the i-th plot
    replayPlot(plot_list[[i]])
    
    # Close the PNG device, which will save the plot as a PNG file
    dev.off()
  }
