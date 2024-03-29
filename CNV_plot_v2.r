rm(list=ls())
setwd('D:/desk/R_wkdir')
library(plotrix)
library(colorRamps)
## 参数设置
input<-'rawdata.txt'
info_file <- "human_genome.fa.sizes.chrom"
output<-'3heatmap.pdf'
###
### 矩阵读取
dd <- read.delim(input,header=T,sep="\t")
pre_info <- read.delim(info_file,header=F,sep="\t")
## 将 genome.fa.sizes.chrom 处理成 plussize
count = 0
counts <- c()
for (i in pre_info[,2]) {
  counts <- c(counts, count)
  count = count + i
}
info <- data.frame(pre_info,counts)
info <- info[!grepl("[A-Za-z]",info[,1]),]  #  这里要求所有的常染色体 都必须是数字!
########################################################
#info <- read.delim("plussize",header=F,sep="\t")



dat<-c();
for(i in 1:nrow(dd) ) {
  for(j in 5:length(dd[i,]) ) {
    samp <- colnames(dd)[j]
    chr <- dd[i,1]
    if(chr )
      str <- dd[i,2]+info[which(info[,1]==chr),3]
    en <- dd[i,3]+info[which(info[,1]==chr),3]
    value <- dd[i,j]
    data <- data.frame(sample=samp,start=str,end=en,CN=value)
    dat <- rbind(dat,data)
  }
}


my_palette <- t(col2rgb(colorRampPalette(c("blue", "white", "red"))(n = 5)))
#colors<-color.scale(as.numeric(dat$CN),my_palette[,1],my_palette[,2],my_palette[,3]);
color.legend<-color.gradient(my_palette[,1],my_palette[,2],my_palette[,3],nslices=31);
color.legend <- color.legend[-16] # 这里将白色区域删除
lev <- seq(-1,1,length.out = 30)
getcolor <- function(CNV)
{
  
  if(CNV==-1){
    return(color.legend[1])
  }else if(CNV == 1){
      return(color.legend[30])
  }else if(CNV==0){
      return("#FFFFFFFF")
  }
  for(i in 1:length(lev)-1)
  {
    if( CNV>=lev[i] && CNV<=lev[i+1] )
    {
      return(color.legend[1+i])
    }
  }
}

colors <- c()
for(cn in dat$CN){
  colors=c(colors,getcolor(cn))
}

dat$color <- colors;


len <- (ncol(dd)-4)

sample=colnames(dd)[5:ncol(dd)]
max = info[nrow(info),2] + info[nrow(info),3]
per=(max/60)
chr=info[,1]


chr_pos <- as.numeric((info[,2]/2+info[,3]))/per
##### 如果遇到染色体无法显示的问题,可以考虑调整间隔,放开下方的注释  通过增大JIANGE 变量 显示所有染色体
# JIANGE = 1.1
# chr_pos_temp <- rev(chr_pos)
# for (i in 1:length((chr_pos_temp))) {
#   if(i==1){
#     next
#   }else{
#       last = i - 1
#       interval <- chr_pos_temp[last]-chr_pos_temp[i]
#       if(interval<JIANGE){
#         chr_pos_temp[i] = chr_pos_temp[i] - (JIANGE-interval)
#       }
#     }
# }
# chr_pos <- rev(chr_pos_temp)
########## 绘制图像 ##############################
pdf(output,width=16,height=4)
par(mar=c(4,12,3,4),cex.axis = 0.7)
plot(1:len+2,1:len,type="n",ylim=c(0,len+1),xlim=c(0,60),bty="n",yaxt="n",xaxt="n",xlab="Chromosome",ylab="",xaxs="i");
axis(2,at=(c(1:len)-0.5),labels=sample,las=2,col = "NA", col.ticks = "NA");
axis(1,at=(chr_pos),labels=chr,las=1,col = "NA", col.ticks = "NA");
axis(1,at=(unique(as.numeric(c(max,info[,3])))/per),labels=NA,las=1,col = "black", col.ticks = "black");
for (i in 1:nrow(dat)) {
  subset<-dat[i,];
  x.left<-subset$start/per;
  x.right<-subset$end/per;
  y.top<- which(subset$sample == sample);
  y.bottom <- y.top-1
  col<-as.character(subset$color);
  rect(x.left,y.bottom,x.right,y.top,col=col,border="NA");
}
lines(c(0,60), c(0,0), type = 'l')
lines(c(0,60), c(len,len), type = 'l')
lines(c(0,0), c(0,len), type = 'l')
lines(c(60,60), c(0,len), type = 'l')
color.legend(53,len+0.3,59,len+0.5,c(-1,1),color.legend,gradient="x");
dev.off()
############################################################





