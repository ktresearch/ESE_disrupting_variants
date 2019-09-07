list<-read.table("../TCGA_cancertype_list.txt",header=FALSE,sep="\t")
raw_list<-length(list[,1])

for (z in 1:raw_list) {
	inputfile<-paste("../",list[z,2],"/analysis_type1/ese_judge_for_Rtest.txt",sep="")
	outputfile<-paste("../",list[z,2],"/analysis_type1/Rtest_result_ks.txt",sep="")
	d<-read.table(inputfile,header=FALSE,sep="\t")
	raw<-length(d[,1])
	for (a in 1:raw) {
		rpkm<-c()
		e<-d[a,5]
		f<-as.character(e)
		g<-strsplit(f,",")
		h<-unlist(g)
		i<-as.numeric(h)
		num<-length(i)
		for (b in 1:num) {
			rpkm<-c(rpkm,i[b])
		}
		dist_mean<-mean(rpkm)
		dist_sd<-sd(rpkm)

		dens<-density(rpkm)
		upper=0
		lower=0
		sum<-sum(dens$y)
		point<-length(dens$x)
		for (c in 1:point) {
			if (dens$x[c] >= d[a,4]) {
				upper = upper + dens$y[c]
			} else {
				lower = lower + dens$y[c]
			}
		}
		pval = 0
		if (sum > 0) {
			pval = upper / sum
		} else {
			pval = 0
		}

		output <- paste(d[a,1],d[a,2],d[a,3],d[a,4],dist_mean,dist_sd,pval,sep="\t")
		write(output,outputfile,append=TRUE)
	}
}

