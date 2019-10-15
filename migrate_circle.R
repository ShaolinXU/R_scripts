#!/usr/local/bin/rscript

options(warn=-1) # supress warning 
#reformat the output file from BayesAss
library(flowR)

args<-commandArgs(T)

bayesAss <- load_ba_results(args[1])

bayesAss <- load_ba_results("run02.txt")

colnames(bayesAss$data) <- c("orgi_reg","dest_reg","flow","sd")

for (i in 1:nrow(bayesAss$data)){
  bayesAss$data[i,1] <- bayesAss$populations[which(bayesAss$populations[,1]==bayesAss$data[i,1]),2]
  bayesAss$data[i,2] <- bayesAss$populations[which(bayesAss$populations[,1]==bayesAss$data[i,2]),2]
}

write.csv(bayesAss$data,"the_migration_data.csv",row.names=F)
write.csv(bayesAss$populations,"population_names_table.csv",row.names=F)

##########################
#build the colorful circle

library(RColorBrewer)
library(migest)
library(ggplot2)
library("circlize")


pal = colorRampPalette(c("blue","yellow","purple","green","cyan"))

df0 <- read.csv("the_migration_data.csv", stringsAsFactors=FALSE)
df1 <- read.csv("population_names_table.csv", stringsAsFactors=FALSE)


circos.par(start.degree = 90, gap.degree = 4, track.margin = c(-0.1, 0.1), points.overflow.warning = FALSE)
par(mar = rep(0, 4))

chordDiagram(x = df0, grid.col = pal(nrow(df1)), transparency = 0.25,
             order = as.character(df1$label), directional = 1,
             direction.type = c("arrows", "diffHeight"), diffHeight  = -0.04,
             annotationTrack = "grid", annotationTrackHeight = c(0.05, 0.1),
             link.arr.type = "big.arrow", link.sort = TRUE, link.largest.ontop = TRUE)

circos.trackPlotRegion(
  track.index = 1, 
  bg.border = NA, 
  panel.fun = function(x, y) {
    xlim = get.cell.meta.data("xlim")
    sector.index = get.cell.meta.data("sector.index")
    reg1 = df1$label[df1$label == sector.index]
    #reg2 = df1$reg2[df1$region == sector.index]
    
    #circos.text(x = mean(xlim), y = ifelse(test = nchar(reg2) == 0, yes = 5.2, no = 6.0),                labels = reg1, facing = "bending", cex = 1.4)
    circos.text(x = mean(xlim), y = 4.4, 
                labels = reg1, facing = "bending", cex = 2)
    circos.axis(h = "top", 
                major.at = seq(from = 0, to = xlim[2], by = ifelse(test = xlim[2]>10, yes = 2, no = 1)), 
                minor.ticks = 1, major.tick.percentage = 0.5,
                labels.niceFacing = FALSE)
  }
)

file.rename("Rplots.pdf",paste(args[1],".pdf",sep=""))



