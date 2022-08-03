library(ggplot2)

args <- commandArgs(trailingOnly = TRUE)

inreads <- read.delim(args[1], header = F, sep = "\t")
colnames(inreads) <- c("run", "sample", "method", "nreads")

inreads$sample <- gsub(".fq.gz", "", inreads$sample)
inreads$sample <- gsub(".fastq.gz", "", inreads$sample)

res <- aggregate(inreads$nreads, by=list(inreads$run,inreads$method), FUN=sum)
colnames(res) <- c("run", "method", "nreads")

complot <- ggplot(res, aes(x=method, y=nreads)) +
  geom_bar(stat="identity", color = "black", size = 0.1) + 
  labs(x = "Method", y = "Read count") +
  theme_gray()

ggsave(args[2], plot = complot, device = "pdf")

gen_met_plot <- function(pldata, plmethod) {
  p = ggplot(pldata, aes(x=method, y=nreads))
  p = p + scale_fill_manual(name = paste("Read count per sample from ", plmethod), labels = unique(pldata$sample), values = pldata$nreads)
  p = p + facet_wrap(pldata$method ~ pldata$sample)
  p = p + geom_bar(stat = "identity", position = "stack", color = "black", size = 0.1)
  p = p + labs(x = "", y = "Read count")
  
  ggsave(paste0(args[3], "/", plmethod, "_plot.pdf"), plot = p, device = "pdf", scale = 1.5)
}

gen_met_plot(inreads[inreads$method == "raw", ], "raw")
gen_met_plot(inreads[inreads$method == "trimmomatic", ], "trimmomatic")
gen_met_plot(inreads[inreads$method == "sortmerna", ], "sortmerna")
gen_met_plot(inreads[inreads$method == "trinity", ], "trinity")

