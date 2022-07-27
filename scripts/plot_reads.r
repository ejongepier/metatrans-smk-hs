args <- commandArgs(trailingOnly = TRUE)

inreads <- read.delim(args[1], header = F, sep = "\t")
colnames(inreads) <- c("run", "sample", "method", "nreads")

res <- aggregate(inreads$nreads, by=list(inreads$run,inreads$method), FUN=sum)
colnames(res) <- c("run", "method", "nreads")

resplot <- res$nreads
names(resplot) <- res$method
resplot <- sort(resplot, decreasing = T)

pdf(args[2], width = 8, height = 10)
barplot(resplot, main = "Aantal reads van specifieke dataset", ylab = "Aantal reads")
dev.off()
