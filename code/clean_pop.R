# Script to clean the Sierra Leone chiefdom statistics.

loadDataClean <- function(l = NULL) {
  
  # Load.
  data <- read.csv(l)
  
  # Clean periods.
  data$Chiefdom <- gsub("\\.", "", data$Chiefdom)
  
  # Clean commas and dashes.
  for (i in 4:ncol(data)) {
    data[,i] <- gsub(",", "", data[,i])
    data[,i] <- gsub("-", "", data[,i])
  }
  
  # Return clean output.
  return(data)
}

# Storing output
clean <- loadDataClean("data/sierra_leone_chiefdom_statistics_original.csv")
write.csv(clean, "data/sierra_leone_chiefdom_statistics_clean.csv", row.names = FALSE)