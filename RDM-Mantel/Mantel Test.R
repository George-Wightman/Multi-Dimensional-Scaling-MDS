library(vegan)


#Set Working Directory 
  setwd("H:\\My Drive\\Nicks Work\\MDS\\Dissimilarity Matricise\\Matrices")
  
#Load Matrices
  #All matrices are dissimilarity data (calculated as 9-similarity rating)
  #Target 
  Free_Rated_csv <- read.csv("FreeRating_dissimilarity_matrix.csv")
    row_names <- Free_Rated_csv[, 1] #Extract the first column to use as row names
    Free_Rated_matrix <- Free_Rated_csv[, -1] #Remove first column
    Free_Rated_matrix <- as.matrix(Free_Rated_matrix)
    rownames(Free_Rated_matrix) <- row_names

  #Dimensions
  Abduction_csv <- read.csv("Abduction_dissimilarity_matrix.csv")
    Abduction_matrix <- Abduction_csv[, -1]
    Abduction_matrix <- as.matrix(Abduction_matrix)
    rownames(Abduction_matrix) <- row_names

  Formidablness_csv <- read.csv("Formidablness_dissimilarity_matrix.csv")
    Formidablness_matrix <- Formidablness_csv[, -1]
    Formidablness_matrix <- as.matrix(Formidablness_matrix)
    rownames(Formidablness_matrix) <- row_names
    
  Friendliness_csv <- read.csv("Friendliness_dissimilarity_matrix.csv")
    Friendliness_matrix <- Friendliness_csv[, -1]
    Friendliness_matrix <- as.matrix(Friendliness_matrix)
    
  Planned.csv <- read.csv("Planned_dissimilarity_matrix.csv")
    Planned_matrix <- Planned.csv[, -1]
    Planned_matrix <- as.matrix(Planned_matrix)
    
    
  
#Performing Mantel Test 
  mantel_abduction <- mantel(Free_Rated_matrix, Abduction_matrix)
    print(mantel_abduction)
    
  mantel_formidablness <- mantel(Free_Rated_matrix, Formidablness_matrix)
    print(mantel_formidablness)
    
  mantel_friendliness <- mantel(Free_Rated_matrix, Friendliness_matrix)
    print(mantel_friendliness)
    
  mantel_planned <- mantel(Free_Rated_matrix, Planned_matrix)
    print(mantel_planned)
    
#Saving Mantel Results 
    correlation_statistics <- c(mantel_abduction$statistic, mantel_formidablness$statistic, mantel_friendliness$statistic, mantel_planned$statistic)
    p_values <- c(mantel_abduction$signif, mantel_formidablness$signif, mantel_friendliness$signif, mantel_planned$signif)
      p_value_corrected <- p.adjust(p_values, method = "fdr")
    
      
    test1<- mantel(Friendliness_matrix, Abduction_matrix)
    test2<- mantel(Formidablness_matrix, Abduction_matrix)
    test3<- mantel(Planned_matrix, Abduction_matrix)
    test4<- mantel(Formidablness_matrix, Friendliness_matrix)
    test5<- mantel(Formidablness_matrix, Planned_matrix)
    test6<- mantel(Planned_matrix, Friendliness_matrix)
    
    
