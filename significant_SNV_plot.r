rm(list=ls())

threshold = 10**(-7.83)
prefix = 'feral'
wkdir = '/public/store5/DNA/Project/Evolution/2021/HT2021-24625_Ramie_population/GEA/population_reseq_feral/population_reseq/HT2021-24625-吴增源-GWAS项目结题报告/5.GWAS/Annotation/'
samples = c()
for(i in dir(wkdir, pattern = "xls")){a=sub("_.+","",i);samples = append(samples,a)}
samples[1] = 'altitude'

# 处理背景
ref <- read.table('/public/store5/DNA/Test/zhangchunyuan/WuZengyuan/HT2021-24625_Ramie_population/population_analysis/ref/genome.fa.sizes.chrom')
colnames(ref) <- c('chr', 'size')
ref$size <- ref$size/10000000

size2 <- c()
counts <- 0
space <- 0.2
for(i in ref$size){
  if(counts==0){
    size2 <- c(size2,i)
  }else{
    size2 <- c(size2,(i+space+size2[length(size2)]))
  }
  counts = counts + 1
}

size3 <- c(0,(size2[1:(length(size2)-1)]+space))
ref$xl <- size3
ref$xr <- size2


outfile <- paste('./',prefix,'_SNV_plot',sep = "")

########################################
#画背景
sample <- c('altitude','bio1','bio2','bio3','bio4','bio5','bio6','bio7','bio8','bio9','bio10','bio11','bio12','bio13','bio14','bio15','bio16','bio17','bio18','bio19')
len <- length(sample)
files <- c('altS','bio1_29','bio2_29','bio3_29','bio4_29','bio5_29','bio6_29','bio7_29','bio8_29','bio9_29','bio10_29','bio11_29','bio12_29','bio13_29','bio14_29','bio15_29','bio16_29','bio17_29','bio18_29','bio19_29')
pdf(file=paste(outfile,".pdf",sep=""),width = 9,height = 6)
a<-dev.cur()
png(file=paste(outfile,".png",sep=""),width = 900,height = 600)
dev.control("enable")
par(mar=c(1,2,1,4))
plot(1:len,1:len,type="n",ylim=c(0,len+1),xlim=c(0,29),bty="n",yaxt="n",xaxt="n",xlab="Chromosome",ylab="",xaxs="i") # 打开画布
axis(4,at=(c(1:len)-0.5),labels=rev(sample),las=2,col = "NA", col.ticks = "NA") # Y轴标签
for(k in (1:length(sample))){
  y_b <- k-0.8
  y_t <- k-0.2
  #画背景
  for(j in (1:dim(ref)[1])){
    x_l <- ref$xl[j]
    x_r <- ref$xr[j]
    rect(x_l,y_b,x_r,y_t,border = "#CCCCCC",angle = 30,lwd = 0, col = "#CCCCCC") # 矩形绘制
  }

  # 处理显著位点
  file <- paste(wkdir,rev(files)[k],"_GWAS.anno.xls",sep = "")
  print(file)
  df <- read.table(file,header = T);
  df <- df[,c(1,2,5)]
  df <- df[df$P.value<threshold, ]
  df$POS <- df$POS/10000000


  pxl <- c()
  pxr <- c()
  for(l in 1:dim(df)[1]){
    pos <- ref[ref$chr==df[l,1],3] + df[l,2]
    pxl <- c(pxl,pos)
    pxr <- c(pxr,pos+0.01)
  }
  if(dim(df)[1]!=0){
    df$pxl <- pxl
    df$pxr <- pxr
  }

  # 画显著的位点
  if(dim(df)[1]!=0){
    for(j in (1:dim(df)[1])){
      x_l <- df$pxl[j]
      x_r <- df$pxr[j]

      lines(x=c(x_l,x_l),y=c(y_b,y_t)) # 显著位点绘制
    }
  }

}
dev.copy(which=a)
dev.off()
dev.off()
rm(a)
