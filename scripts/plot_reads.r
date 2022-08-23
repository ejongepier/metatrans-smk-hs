library(ggplot2)

args <- commandArgs(trailingOnly = TRUE)
#args <- c("/home/thomas/Werk/demo_results_cluster/plots/reads_results.tsv")

inreads <- read.delim(args[1], header = F, sep = "\t")
colnames(inreads) <- c("run", "sample", "method", "nreads", "sample_id")

inreads$sample <- gsub(".fq.gz", "", inreads$sample)
inreads$sample <- gsub(".fastq.gz", "", inreads$sample)

res <- aggregate(inreads$nreads, by=list(inreads$run,inreads$method), FUN=sum)
colnames(res) <- c("run", "method", "nreads")

complot <- ggplot(res, aes(x=method, y=nreads)) +
  geom_bar(stat="identity", color = "black", size = 0.1) + 
  labs(x = "Method", y = "Read count") +
  theme_gray()

complot
ggsave(args[2], plot = complot, device = "pdf")

sample_reads <- aggregate(inreads$nreads, by=list(inreads$run, inreads$method, inreads$sample_id), FUN=sum)
colnames(sample_reads) <- c("run", "method", "sample_id", "nreads")

gen_met_plot <- function(pldata, plmethod) {
  p = ggplot(pldata, aes(x=method, y=nreads))
  p = p + scale_fill_manual(name = paste("Read count per sample from ", plmethod), labels = unique(pldata$sample_id), values = pldata$nreads)
  p = p + facet_wrap(~ pldata$sample_id)
  p = p + geom_bar(stat = "identity", position = "dodge", color = "black", size = 0.1)
  p = p + labs(x = "", y = "Read count")
  ggsave(args[3], plot = p, device = "pdf", scale = 1.5)
}

gen_met_plot(sample_reads, "all")

