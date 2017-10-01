#don't forget to change the path to your file! ;) 


#loading the data
setwd("D:\\Purdue Courses\\Fall 2017\\MGMT 590 R\\Project\\Dataset")
fileEF <- "D:\\Purdue Courses\\Fall 2017\\MGMT 590 R\\Project\\Dataset\\emissions_fields.csv"
fileE <- "D:\\Purdue Courses\\Fall 2017\\MGMT 590 R\\Project\\Dataset\\emissions.csv"
fileVF <- "D:\\Purdue Courses\\Fall 2017\\MGMT 590 R\\Project\\Dataset\\vehicle_fields.csv"
fileV <- "D:\\Purdue Courses\\Fall 2017\\MGMT 590 R\\Project\\Dataset\\vehicles.csv"


emmissionsFileds <- read.table(file=fileEF, header=T, sep=",")
emmissions <- read.table(file=fileE, header=T, sep=",")
vehicles_fields <- read.table(file=fileVF, header=T, sep=",")
vehicles <- read.table(file=fileV, header=T, sep=",")

#merging the vehicles and emmissions datasets
vehicles <- merge(vehicles, emmissions, by='id')

#selecting new models
newVehicles <- subset(vehicles, (vehicles$year == 2017 | vehicles$year == 2018))

#excluding eletric vehicles so we can compare only with gas
newVehicles <- subset(newVehicles, charge120 == 0 & charge240 == 0)

#adding prices - random between 15000 and 70000
newVehicles$Price <- sample(15000:70000, length(newVehicles$id), replace=TRUE)


#An "eco-friendly" car has (score >= 8) and (ghgScore >= 8)
#if you want to do more classifications, 
#Excellent Eco-Friendy: both >= 8
#Good: ghgScore>= 8 and score > 6
#Medium: ghgScore >= 5 score > 5
# Rest is bad
newVehicles$ecoFriendly <- ifelse((newVehicles$ghgScore >= 8 & newVehicles$score >= 8), "Nature Lover", 
                                  ifelse((newVehicles$ghgScore >= 8 & newVehicles$score > 5), "Green Car",
                                         ifelse((newVehicles$ghgScore >= 5 & newVehicles$score > 5), "Kinda Green", "It's a monster!")))


    
#subsetting the variables we will analyze 
newVehicles <- newVehicles[, c("make", "model",  "Price", "city08","highway08","cylinders"
                              , "displ", "drive", "fuelCost08", "fuelType1", "ecoFriendly"
                              )]

#plots

#Fuel Cost x Cylinders 
boxplot(fuelCost08~cylinders,data=newVehicles, main="Annual Fuel Cost x Cylinders", 
        xlab="cyl", ylab="Annual Fuel Cost",col="darkgreen")

#Fuel Cost x displ 
ggplot(newVehicles, aes(x = displ, y=fuelCost08)) + geom_point() + geom_point(aes(color = displ)) +
        labs(x="Engine displacement L", y="Annual Fuel Cost", title="Annual Fuel Cost x Engine Displ")

#fuel cost x city mpg
plot(fuelCost08~city08,data=newVehicles, main="Annual Fuel Cost x City MPG", 
        xlab="City MPG", ylab="Annual Fuel Cost",col="red")

#fuel cost x highway mpg
plot(fuelCost08~highway08,data=newVehicles, main="Annual Fuel Cost x Highway MPG", 
     xlab="Highway MPG", ylab="Annual Fuel Cost",col="blue")

#fuel cost x eco friendly
newVehicles$ecoFriendly <- factor(newVehicles$ecoFriendly, 
                                     levels = c("Nature Lover", "Green Car", "Kinda Green", "It's a monster!"), 
                                  ordered = T)
ggplot(newVehicles, aes(x = as.factor(ecoFriendly), y=fuelCost08)) + geom_point() + geom_point(aes(color = ecoFriendly)) +
    labs(x="Eco Friendly Scale", y="Annual Fuel Cost", title="Annual Fuel Cost x Eco Friendly")



# just checking
str(newVehicles)
table(newVehicles$cylinders)
table(newVehicles$displ)
table(newVehicles$drive)
table(newVehicles$fuelCost08)
table(newVehicles$fuelType1)
table(newVehicles$ecoFriendly)
