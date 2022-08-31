args <- commandArgs(trailingOnly = TRUE)
remotes::install_github("missuse/ragp")

library(ragp)
library("topGO")

#exprdata <- read.delim(args[1], header = T, sep = "\t")
exprdata <- read.delim("trinity-de.isoform.counts.matrix.C_vs_MA.edgeR.DE_results", header = T, sep = "\t")

#testdata <- read.delim(args[0], header = F, sep = "\t")
pfamdata <- read.delim("pfam_test.tsv", header = F, sep = "\t")
colnames(pfamdata) <- c("TRINITY_ID", "MD5", "Sequence length", "Analysis", 
                        "Pfam family", "Signature description", "Start location", 
                        "Stop location", "Score", "Status", "Date", "InterPro accession", 
                        "InterPro description")
pfamdata <- pfam2go(pfamdata, "Pfam family")
pfamdata <- na.exclude(pfamdata)

datasetgenes <- exprdata$FDR
names(datasetgenes) <- rownames(exprdata)

genesOfInterest <- rownames(exprdata)[exprdata$FDR < 0.05]

geneList <- factor(as.integer(rownames(exprdata) %in% genesOfInterest))
names(geneList) <- rownames(exprdata)
genes <- as.vector(geneList)

GOID <- as.list(pfamdata$GO_acc)
names(GOID) <- pfamdata$TRINITY_ID
GOID <- tapply(unlist(GOID, use.names = TRUE), rep(names(GOID), lengths(GOID)), FUN = c)
GOID <- lapply(GOID, function(x) {attributes(x) <- NULL; x })
str(head(GOID))

#GOdata <- new("topGOdata", description = "Test data", ontology = "CC", allGenes = geneList,
#                  nodeSize = args[2], annot = annFUN.gene2GO, gene2GO=GOID)
GOdata <- new("topGOdata", description = "Test data", ontology = "BP", allGenes = geneList,
              nodeSize = 10, annot = annFUN.gene2GO, gene2GO=GOID)

resultsFisher <- runTest(GOdata, statistic = "fisher")
resultsFisher
