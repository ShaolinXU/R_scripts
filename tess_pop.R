#!/usr/local/bin/rscript

library(tess3r)
library(ggpubr)
library(RColorBrewer)
library(maps)
library(ggplot2)
library(rworldmap)
library(ggpubr)
pal = colorRampPalette(c("blue","yellow","purple","green","cyan"))

args<-commandArgs(T)

the_raw_data <- read.csv(args[1])
tess_file <- tess2tess3(the_raw_data,TESS = T,FORMAT = 2,diploid = T,extra.column = args[2])

tess_res <- tess3(X = tess_file$X, coord = tess_file$coord,
                 K = 1:args[3], ploidy = 2, openMP.core.num = 4)

png(filename = "Best_k.png",width = 6*300,height=4*300,res=300)
plot(tess_res, pch = 19, col = "blue",
     xlab = "Number of ancestral populations",
     ylab = "Cross-Validation score")
dev.off()

map.polygon <- getMap(resolution = "low")

min_long <- min(tess_file$coord[,1])-2
max_long <- max(tess_file$coord[,1])+2
min_lat <- min(tess_file$coord[,2])-2
max_lat <- max(tess_file$coord[,2])+2

plot_list <- list()

for (i in 2:args[3]){
  the_k <- i
  Q.matrix <- qmatrix(tess_res, K = the_k)
  pl <- ggtess3Q(Q.matrix, tess_file$coord, map.polygon = map.polygon,col.palette =pal(the_k) ) 
  plot_list[[i-1]] <- pl +
    geom_path(data = map.polygon, aes(x = long, y = lat, group = group)) +
    xlim(min_long, max_long) + 
    ylim(min_lat,max_lat) + 
    coord_equal(ratio = 1.5) + 
    geom_point(data = as.data.frame(tess_file$coord), aes(x = longitude, y = latitude), size = .2) + 
    xlab("Longitute") +
    ylab("Latitude") + 
    theme_bw()
}

the_row_num <- floor(sqrt(as.integer(args[3])))
the_col_num <- ceiling(sqrt(as.integer(args[3])))

ggarrange(plotlist=plot_list, 
          labels = paste("K",c(2:args[3]),sep="="),
          ncol = the_col_num, nrow = the_row_num)

ggsave("tess_pop_structure.pdf", width = 20, height = 20, units = "cm")
file.remove("Rplots.pdf")