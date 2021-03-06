### Exploring relationships between political participation and educational outcomes ###
### MP 20/05/15 ###
### Now a fully merged working df + written out excel file ###


setwd("~/GitHub/election2015")

library(openxlsx)
library(reshape)
library(pastecs)
library(ggplot2)
library(dplyr)


# setting up election datasets --------------------------------------------

# this analysis has been updated to try and correct some merging problems between the turnout and votes datasets

# before correcting, there were 3887 cases in "election" - now there are 3971

# make a turnout dataframe
turnout <- read.xlsx(xlsxFile = "turnout2015_clean.xlsx", sheet = 1, startRow = 1, skipEmptyRows = TRUE)

votes <- read.csv("~/GitHub/election2015/votes2015.csv")
View(votes)

table(votes$position) # look at distribution of positions
class(votes$position)
votes <- votes[votes$position != 1, ] # get rid of empty first rows
votes$position <- votes$position - 1 # re-rank candidates

str(votes) # look at data structure
str(turnout)
turnout$constituency <- turnout$constituency_original
# merge together turnout and votes data frames

election <- merge(votes, turnout, by = "constituency")
names(election)

levels(votes$party)


# making separate party datasets ------------------------------------------


ukip <- election[election$party == "UKIP", ] # keep only UKIP candidates
lab <- election[election$party == "LAB", ] # keep only LAB candidates
con <- election[election$party == "CON", ] # keep only CON candidates
ld <- election[election$party == "LD", ] # keep only LD candidates


# making gcse results datasets --------------------------------------------

# make GCSE results dataframes
gcse_years <- c(2011, 2012, 2013, 2014)

x = 5
for (i in gcse_years) {
     z <- paste0("gcse", i)
     y <- read.xlsx(xlsxFile = "turnout2015_clean.xlsx", sheet = x, startRow = 1, skipEmptyRows = TRUE)
     assign(z, y)
     #str(y)
     x = x-1
     rm(y)
}

# check structure of gcse dfs
sapply(gcse2011, class)
table(gcse2011$Achieving.the.English.Baccalaureate)
names(gcse2011)

# check structure of turnout df
str(turnout)
turnout <- rename(turnout, c(constituency_renamed = "constituency_name"))
names(turnout) # check renaming of vars
turnout <- turnout[, -c(1,2,3,4,5)] # get rid of extra columns

# rename gcse df vars
names(gcse2011)

gcse2011 <- rename (gcse2011, c(constituency.code = "code","5+.A*-C.grades" = "AC", "5+.A*-G.grades" = "AG", "5+.A*-C.grades.inc..English.and.mathematics.GCSEs" = "ACEM", "5+.A*-G.grades.inc..English.and.mathematics.GCSEs" = "AGEM", "A*-C.in.English.and.mathematics.GCSEs" = "EM", Entering.the.English.Baccalaureate = "EEB", Achieving.the.English.Baccalaureate = "AEB"))
colnames(gcse2011) <- paste(colnames(gcse2011), "2011", sep = "_")
names(gcse2011)

gcse2012 <- rename (gcse2012, c(constituency.code = "code","5+.A*-C.grades" = "AC", "5+.A*-G.grades" = "AG", "5+.A*-C.grades.inc..English.and.mathematics.GCSEs" = "ACEM", "5+.A*-G.grades.inc..English.and.mathematics.GCSEs" = "AGEM", "A*-C.in.English.and.mathematics.GCSEs" = "EM", Entering.the.English.Baccalaureate = "EEB", Achieving.the.English.Baccalaureate = "AEB"))
colnames(gcse2012) <- paste(colnames(gcse2012), "2012", sep = "_")
names(gcse2012)

gcse2013 <- rename (gcse2013, c(constituency.code = "code","5+.A*-C.grades" = "AC", "5+.A*-G.grades" = "AG", "5+.A*-C.grades.inc..English.and.mathematics.GCSEs" = "ACEM", "5+.A*-G.grades.inc..English.and.mathematics.GCSEs" = "AGEM", "A*-C.in.English.and.mathematics.GCSEs" = "EM", Entering.the.English.Baccalaureate = "EEB", Achieving.the.English.Baccalaureate = "AEB"))
colnames(gcse2013) <- paste(colnames(gcse2013), "2013", sep = "_")
names(gcse2013)

gcse2014 <- rename (gcse2014, c(constituency.code = "code","5+.A*-C.grades" = "AC", "5+.A*-G.grades" = "AG", "5+.A*-C.grades.inc..English.and.mathematics.GCSEs" = "ACEM", "5+.A*-G.grades.inc..English.and.mathematics.GCSEs" = "AGEM", "A*-C.in.English.and.mathematics.GCSEs" = "EM", Entering.the.English.Baccalaureate = "EEB", Achieving.the.English.Baccalaureate = "AEB"))
colnames(gcse2014) <- paste(colnames(gcse2014), "2014", sep = "_")
names(gcse2014)

# make a constituency variable with the same name
gcse2011$cons <- gcse2011$constituency_name_2011
gcse2012$cons <- gcse2012$constituency_name_2012
gcse2013$cons <- gcse2013$constituency_name_2013
gcse2014$cons <- gcse2014$constituency_name_2014


# merging gcse datasets ---------------------------------------------------


# merge the gcse datasets
gcsemerge <- merge(gcse2011, gcse2012, by = "cons")
gcsemerge <- merge(gcsemerge, gcse2013, by = "cons")
gcsemerge <- merge(gcsemerge, gcse2014, by = "cons")
str(gcsemerge)

# get rid of duplicate constituency name vars
gcsemerge$constituency_name_2011 <- NULL
gcsemerge$constituency_name_2012 <- NULL
gcsemerge$constituency_name_2013 <- NULL
gcsemerge$constituency_name_2014 <- NULL

colnames(gcsemerge) # see column names and positions in gcsemerge


# making gcse averages across years ---------------------------------------

gcsemerge$acem_avg <- rowMeans(gcsemerge[, c(5, 14, 23, 32)])
table(gcsemerge$acem_avg)
library(pastecs)
stat.desc(gcsemerge$acem_avg)

gcsemerge$eeb_avg <- rowMeans(gcsemerge[, c(9, 18, 27, 36)])
summary(gcsemerge$eeb_avg)

gcsemerge$aeb_avg <- rowMeans(gcsemerge[, c(10, 19, 28, 37)])
summary(gcsemerge$aeb_avg)


# merge gcse data with each party’s data ----------------------------------

# merge in the gcse data for each party
names(gcsemerge)
names(ukip)
ukip$cons <- ukip$constituency_renamed
ukip_gcse <- merge(ukip, gcsemerge, by = "cons")

# ukip has 610 obs; ukip_gcse has 527 obs - which ones are missing?
ukipdiff <- setdiff(ukip$cons, ukip_gcse$cons)
ukipdiff # fine, the 83 that are missing are in Scotland, Wales and NI

lab$cons <- lab$constituency_renamed
lab_gcse <- merge(lab, gcsemerge, by = "cons")

con$cons <- con$constituency_renamed
con_gcse <- merge(con, gcsemerge, by = "cons")

ld$cons <- ld$constituency_renamed
ld_gcse <- merge(ld, gcsemerge, by = "cons")

# graphs by party ------------------------------------------------------------------

#ukip
names(ukip_gcse)
g1_ukip_acem <- ggplot(ukip_gcse, aes(acem_avg, share)) + geom_point() + geom_smooth(method = "lm", colour = "purple", alpha = 0.1, fill = "purple") + labs (x = "Average 5A*C inc E&M 2011-2014", y = "UKIP vote share 2015") 
# + ggtitle ("Relationship between constituency average GCSE performance \n and UKIP vote share") +  theme(plot.title = element_text(size = 12))
g1_ukip_acem

cor(ukip_gcse$acem_avg, ukip_gcse$share)
cor.test(ukip_gcse$acem_avg, ukip_gcse$share)
# library(psych) # masked as it stops ggplot working
describe(ukip_gcse$acem_avg)
describe(ukip_gcse$share)

m1 <- lm(ukip_gcse$share ~ ukip_gcse$acem_avg)
summary(m1)

g2_ukip_eeb <- ggplot(ukip_gcse, aes(eeb_avg, share)) + geom_point() + geom_smooth(method = "lm", colour = "purple", alpha = 0.1, fill = "purple") + labs (x = "average % of pupils entered for EBacc 2011-2014", y = "UKIP vote share 2015")
g2_ukip_eeb
g3_ukip_aeb <- ggplot(ukip_gcse, aes(aeb_avg, share)) + geom_point() + geom_smooth(method = "lm", colour = "purple", alpha = 0.1, fill = "purple") + labs (x = "average % of pupils achieving EBacc 2011-2014", y = "UKIP vote share 2015")
g3_ukip_aeb

#labour
names(lab_gcse)
g1_lab_acem <- ggplot(lab_gcse, aes(acem_avg, share)) + geom_point() + geom_smooth(method = "lm", colour = "red", alpha = 0.1, fill = "red") + labs (x = "average 5A*C inc E&M 2011-2014", y = "Labour vote share 2015")
g1_lab_acem

require(psych)
describe(lab_gcse$acem_avg)
describe(lab_gcse$share)

# fixing missing constituencies -------------------------------------------

# seems like there is still one constituency missing here between ukip_gcse and lab_gcse - in the latter, n = 532

ukip_constit <- (ukip_gcse$cons)
lab_constit <- (lab_gcse$cons)

missing <- ukip_constit %in% lab_constit
missing[missing == FALSE] # one is missing - eyeballing it I can see it's number 79 in the list
ukip_constit[79] # Buckingham
lab_constit[79]

# after looking through some of the dfs, it seems that only Greens and UKIP put forward a candidate in Buckingham, because it's where the speaker John Bercow runs. So there'll be 533 constituencies in the UKIP df, but 532 in the others


# returning to graphing ---------------------------------------------------


require(ggplot2)
g2_lab_eeb <- ggplot(lab_gcse, aes(eeb_avg, share)) + geom_point() + geom_smooth(method = "lm", colour = "red", alpha = 0.1, fill = "red") + labs (x = "average % of pupils entered for EBacc 2011-2014", y = "Labour vote share 2015")
g2_lab_eeb
g3_lab_aeb <- ggplot(lab_gcse, aes(aeb_avg, share)) + geom_point() + geom_smooth(method = "lm", colour = "red", alpha = 0.1, fill = "red") + labs (x = "average % of pupils achieving EBacc 2011-2014", y = "Labour vote share 2015")
g3_lab_aeb

#tory
names(con_gcse)
g1_con_acem <- ggplot(con_gcse, aes(acem_avg, share)) + geom_point() + geom_smooth(method = "lm", colour = "blue", alpha = 0.1, fill = "blue") + labs (x = "Average 5A*C inc E&M 2011-2014", y = "Conservative vote share 2015") + ggtitle ("Relationship between constituency average GCSE performance \n and Conservative vote share")
g1_con_acem

m2 <- lm(con_gcse$share ~ con_gcse$acem_avg)
summary(m2)

cor(con_gcse$acem_avg, con_gcse$share)
cor.test(con_gcse$acem_avg, con_gcse$share)
library(psych)
describe(con_gcse$acem_avg)
describe(con_gcse$share)
library(ggplot2)

g2_con_eeb <- ggplot(con_gcse, aes(eeb_avg, share)) + geom_point() + geom_smooth(method = "lm", colour = "blue", alpha = 0.1, fill = "blue") + labs (x = "average % of pupils entered for EBacc 2011-2014", y = "Conservative vote share 2015")
g2_con_eeb
g3_con_aeb <- ggplot(con_gcse, aes(aeb_avg, share)) + geom_point() + geom_smooth(method = "lm", colour = "blue", alpha = 0.1, fill = "blue") + labs (x = "average % of pupils achieving EBacc 2011-2014", y = "Conservative vote share 2015")
g3_con_aeb

#lib dems
names(ld_gcse)
g1_ld_acem <- ggplot(ld_gcse, aes(acem_avg, share)) + geom_point() + geom_smooth(method = "lm", colour = "yellow", alpha = 0.3, fill = "yellow") + labs (x = "average 5A*C inc E&M 2011-2014", y = "Liberal Democrat vote share 2015")
g1_ld_acem
g2_ld_eeb <- ggplot(ld_gcse, aes(eeb_avg, share)) + geom_point() + geom_smooth(method = "lm", colour = "yellow", alpha = 0.3, fill = "yellow") + labs (x = "average % of pupils entered for EBacc 2011-2014", y = "Liberal Democrat vote share 2015")
g2_ld_eeb
g3_ld_aeb <- ggplot(ld_gcse, aes(aeb_avg, share)) + geom_point() + geom_smooth(method = "lm", colour = "yellow", alpha = 0.3, fill = "yellow") + labs (x = "average % of pupils achieving EBacc 2011-2014", y = "Liberal Democrat vote share 2015")
g3_ld_aeb


# recoding constituency results -------------------------------------------

str(election$result)
election$resultfac <- as.factor(election$result)
levels(election$resultfac)

# setting up the recoded groups
conservative <- levels(election$resultfac)[1:4]
other <- levels(election$resultfac)[c(5:8, 14:20, 22:23)]
labour <- levels(election$resultfac)[9:12]
libdem <- levels(election$resultfac)[13]


election$winner <- NA
election$winner[election$resultfac %in% conservative] <- "CON"
election$winner[election$resultfac %in% other] <- "OTH"
election$winner[election$resultfac %in% labour] <- "LAB"
election$winner[election$resultfac %in% libdem] <- "LIB"
table(election$winner)

# turnout vs. majority
g1_turnout <- ggplot(election, aes(turnout, majority)) + geom_point(aes(colour = factor(winner))) + geom_smooth(method = "lm", colour = "grey", alpha = 0.3, fill = "grey") + labs (x = "constituency turnout %", y = "constituency majority %", colour = "Winner")
g1_turnout

election_lab <- election[which(election$winner=="LAB"), ]
g2_turnout_lab <- ggplot(election_lab, aes(turnout, majority)) + geom_point(colour = "red") + geom_smooth(method = "lm", colour = "grey", alpha = 0.3, fill = "grey") + labs (x = "constituency turnout %", y = "constituency majority %", colour = "Labour") + theme(legend.position = "none") + ggtitle("Labour turnout vs. majority")
g2_turnout_lab

election_con <- election[which(election$winner=="CON"), ]
g3_turnout_con <- ggplot(election_con, aes(turnout, majority)) + geom_point(colour = "blue") + geom_smooth(method = "lm", colour = "grey", alpha = 0.3, fill = "grey") + labs (x = "constituency turnout %", y = "constituency majority %", colour = "Conservatives") + theme(legend.position = "none") + ggtitle("Conservative turnout vs. majority")
g3_turnout_con


# merge election and gcsemerge datasets -----------------------------------

gcsemerge$constituency <- gcsemerge$cons #get a same name var to merge
election_education <- merge(election, gcsemerge, by = "constituency")
election_education <- election_education[order(election_education$constituency, election_education$position), ]
names(election_education)
keep_el_ed <- names(election_education)[c(1:12, 14:15, 17:20, 23:30, 32:39, 41:60)]
el_ed <- election_education[keep_el_ed]

# write out the election_education file
# write.xlsx(el_ed, file = "election_education.xlsx", colNames = T)


# something is wrong with the election_education.xlsx file
# not all the cases have come through
# check merge names - which constituency var has caused difficulties?
# having scanned through, looks like it's the gcsemerge and electionmerge stage where it's gone wrong
# Need to correct the constituency merge variable

names(gcsemerge)
names(election)
names(election_education) # checking the excel file, there are no Dorset constituencies listed, something is wrong with the match
# this is strange, as the write-out file below shows that there ARE Dorset constituencies in the election df.

# # write out the files to take a look
# write.xlsx(gcsemerge, file = "gcsemerge_temp.xlsx", colNames = T)
# write.xlsx(election, file = "election_temp.xlsx", colNames = T)

# check the levels of the constituency variable in each df
levels(election$constituency) # 194 is Dorset Mid and Poole North
levels(gcsemerge$constituency)
class(gcsemerge$constituency)
str(gcsemerge$constituency) # turns out constituency isn't a var in there

levels(gcsemerge$cons)
str(gcsemerge$cons) #annoying, it's a character var
table(gcsemerge$cons) #ok so here it's Mid Dorset and North Poole, which is what we need for the shapefile. So the gcsemerge df is ok, it's the election one

names(election)
# ok, looks like I should merge gcsemerge$cons with election$constituency_renamed


# merge election and gcsemerge datasets v2 -----------------------------------

gcsemerge$constituency_renamed <- gcsemerge$cons #get a same name var to merge
election_education <- merge(election, gcsemerge, by = "constituency_renamed") #let's merge on the renamed var instead
table(election_education$constituency_renamed)
election_education <- election_education[order(election_education$constituency_renamed, election_education$position), ]
names(election_education)


# # write out the election_education file
# write.xlsx(election_education, file = "election_education_v3.xlsx", colNames = T) # cotswolds issues fixed