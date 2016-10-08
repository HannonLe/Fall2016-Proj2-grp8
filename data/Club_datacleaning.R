club <- Liquor_Authority_Quarterly_List_of_Active_Licenses
vars <- c("Doing.Business.As..DBA.", "License.Type.Name", "License.Type.Code", "City", "Latitude", "Longitude", "Location", "Actual.Address.of.Premises..Address1.","Zip")
club <- club[ ,vars]
club <- subset(club, club$City == "NEW YORK" & club$License.Type.Code == "CL")
vars <- c("Latitude", "Longitude", "Actual.Address.of.Premises..Address1.","Zip")
club <- club[ ,vars]
write.csv(club, file = "club_location.csv")
