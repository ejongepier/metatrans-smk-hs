args <- commandArgs(trailingOnly = TRUE)

inreads <- read.delim(args[1], header = T, sep = "\t")
amount_samples <- (nrow(inreads)-1)/3

raw <- sum(inreads[1:amount_samples,"num_seqs"])
trimmomatic <- sum(inreads[(amount_samples+1):(amount_samples*2),"num_seqs"])
sortmerna <- sum(inreads[(amount_samples*2+1):(amount_samples*3),"num_seqs"])

reads <- c(raw, trimmomatic, sortmerna)
names(reads) <- c("raw","trimmomatic","sortmerna")

pdf(args[2], width = 10, height = 8)
barplot(reads, main = "Aantal reads van specifieke dataset", ylab = "Aantal reads")
dev.off()
