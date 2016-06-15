library(ggplot2)
library(reshape2)
library(grid)
library(Cairo)

args = commandArgs(TRUE)

input_table = args[1]
output_png = args[2]

options(bitmapType='cairo')
variant_table <- read.table( input_table, sep="\t", header = TRUE, skip=1, colClasses="character")
sample_column <- variant_table[,1]
col2cvt <- 3:8
variant_table[,col2cvt] <- lapply(variant_table[,col2cvt],function(x){as.numeric(gsub("%", "", x))})

variant_table_malted <- variant_table[,col2cvt]
final_table <- cbind(sample_column, variant_table_malted)
colnames(final_table) <- c("sample_id","1X","5X","10X","20X","30X","50X")

ggplot_data <- melt(final_table)
#colnames(ggplot_data) <- c("sample_id","coverage","percentage(%)")

#--------------Make a Boxplt-----------------------

CairoPNG( output_png, width=2200, height=1200, res=480)

p <- ggplot (ggplot_data, aes(factor(variable),value))
p + geom_boxplot (aes(fill = factor(variable))) + 
    labs(x = "coverage", y = "percentage(%)") +
    theme_bw() +
    guides(fill=guide_legend(title = "coverage"))

dev.off()
