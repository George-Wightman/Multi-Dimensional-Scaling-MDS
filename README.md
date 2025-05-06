Multidimensional Scaling (MDS) Scripts.
       This repository contains R scripts used for analyzing behavioral similarity data using various MDS techniques, including INDSCAL, metaMDS, and smacofSym. All scripts operate on pairwise similarity ratings collected from participants and output MDS configurations for dimensionality reduction and visualization.
      
      Common Structure Across Scripts
      All scripts follow this shared workflow:
        
        Data Loading
          Reads participant similarity ratings and action label files from two datasets (Set1 and Set2).
        
        Preprocessing
          Transforms similarity ratings into dissimilarity (by subtracting from 9).
          Maps numeric stimulus codes to action names.
          Matrix Construction
          For each participant or across all participants, constructs dissimilarity matrices.
          
        Dimensionality Reduction
          Applies a variant of MDS (see below).
          Output
          Saves MDS coordinates and stress values; optionally plots configurations or saves dissimilarity matrices.
      
      Script Descriptions
        INDSCAL.R
          Uses INDSCAL from the smacof package.
          Analyzes participant-level dissimilarity matrices jointly to produce a shared MDS space and individual weightings per dimension.
          Outputs:
            Set_INDSCAL_D_gspace.csv: Common configuration space.
            Set_INDSCAL_D_cweights.csv: Dimension weights per participant.
            Common-space 2D plot.
          
        MDS_metaMDS_PerParticipant_vegan.R
          Uses metaMDS from the vegan package, per participant.
          Outputs participant-specific MDS coordinates and stress values.
          Output file: Set_D_metaMDS_PerP.csv.
          
        MDS_metaMDS_vegan.R
          Uses metaMDS from vegan, on averaged dissimilarity data across all participants.
          Outputs:
            Scree plots to evaluate dimensionality.
            2D projection plots across dimension pairs.
            dissimilarity_matrix.csv.
        
        MDS_smacofSym_PerParticipant_smacof.R
          Uses smacofSym() from the smacof package, per participant.    
          Similar to the metaMDS-per-participant script but uses ordinal scaling.
          Outputs:
            Set_D_smacof_PerP.csv: Coordinates and stress per participant.
            Optional: MDS-coordinate regression against external model features.
        
        MDS_smacofSym_smacof.R
          Uses smacofSym() on averaged dissimilarity data.
          Outputs:
            Shepard and scree plots    
            2D projection plots across all dimensions.
            dissimilarity_matrix.csv.
      
      Dependencies
        All scripts assume the following R packages are installed:
          library(readr)
          library(tidyverse)
          library(ggplot2)
          library(vegan)     # For metaMDS
          library(smacof)    # For INDSCAL and smacofSym
          library(broom)     # For optional regression summaries
        
      Notes
        metaMDS may produce warnings (e.g. “stress nearly zero”) if input data is limited or overly uniform. This does not indicate failure.
        INDSCAL is ideal for identifying shared representational structure across participants.
        All scripts assume that Set1_Data and Set2_Data directories exist and contain the required CSV files

Representational-Dissimilarity-Marticies and Mantel Tests.
      These scripts handle post-MDS matrix processing, including reordering, visualization, and statistical comparisons between dissimilarity structures using Mantel tests.
      
      MakeAndReorderRDMs.R
        Reorders a single dissimilarity matrix based on different psychological dimensions (e.g. Formidable, Friendly, Planned, Abducting).
        Normalizes each reordered matrix to a common range.
        Generates and saves heatmap visualizations for each reordered matrix.
        Saves the reordered matrices as CSV files for further analysis.
        
        Key Outputs:
          .png heatmaps for each matrix and dimension.
          .csv files for each reordered dissimilarity matrix.
        
        Expected Inputs:
          dissimilarity_matrix: A symmetric matrix of item dissimilarities.
          stimuli_labels: A dataframe mapping stimulus codes to names and dimensional ratings.
        
        Usage Notes:
          You may need to define or load dissimilarity_matrix and stimuli_labels before running this script.
          Output folder is set manually using setwd().
      
      Mantel Test.R
        Performs pairwise Mantel tests between a target dissimilarity matrix (e.g., participant free ratings) and each dimension-specific matrix (Formidableness, Friendliness, Abduction, Planned).
        Also computes Mantel tests among the predictor matrices themselves to assess their intercorrelations.
        Outputs test statistics and FDR-corrected p-values.
        
        Key Outputs:
          Console output of Mantel test results.
          correlation_statistics and FDR-corrected p_values for interpretation.
        
        Expected Inputs:
          .csv dissimilarity matrices located in the specified working directory.
