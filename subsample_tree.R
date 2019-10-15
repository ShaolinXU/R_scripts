#!/usr/local/bin/Rscript
# _*_ coding: utf-8 _*_
library('getopt')
library(ape)
command=matrix(c( 
  'help', 'h', 0,'logical', '帮助文档',
  'treefile', 't', 1, 'character', '判断值的结果',
  'num_tree', 'n', 1, 'character', '标准化的判断值的结果',
  "out_file","o",1,"character","输出文件的名称",
  "burnin","b",1,"double","burnin 的比例"),
  byrow=T,ncol=5)

args=getopt(command)

if (!is.null(args$help) || is.null(args$treefile) || is.null(args$out_file) ) {
  cat(paste(getopt(command, usage = T), "\n"))
  q(status=1)
}

# set some reasonable defaults for the options that are needed,
# but were not specified.
if ( is.null(args$num_tree    ) ) { args$num_tree    = 100     }
if ( is.null(args$burn_in      ) ) { args$burn_in      = 0.2     }
if ( is.null(args$out_file   ) ) { args$out_file   = "resampled.trees"    }
# if ( is.null(args$verbose ) ) { args$verbose = FALSE }

the_raw_trees <- read.nexus(args$treefile)

burnin <- as.integer(args$burnin)

the_length <- as.integer(length(the_raw_trees)*burnin):length(the_raw_trees)
print(the_length)
the_index <- sample(the_length,size = as.integer(args$num_tree),replace = F)

write.nexus(the_raw_trees[the_index],file = args$out_file)
