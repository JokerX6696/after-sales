#!/public/store5/DNA/Test/zhengfuxing/conda/bin/Rscript
# conda activate /public/store5/DNA/Test/zhengfuxing/conda
# Rscript plot.r -o ./output -i indel.annotation.xls -s snp.annotation.xls
library("optparse")
# 传参
option_list <- list(
  make_option(c("-i","--indel"),type="character",help="input file :  indel.annotation.xls "),
  make_option(c("-s","--snp"),type="character",help="input file :  snp.annotation.xls "),
  make_option(c("-o","--output"), help="output dir")

)

opt <- parse_args(OptionParser(option_list=option_list))
all_args <- names(opt)
df_indel <- opt$i
df_snp <- opt$s
output <- opt$o
### 判断参数是否合格
if(!"output" %in% all_args){
  print("请输入参数 -o 指定输出目录")
  q()
}else if(!"indel" %in% all_args & !"snp" %in% all_args){
  print("-i -s 至少存在一个！")
  q()
}

###
library("CMplot")

list <- c()

if("indel" %in% all_args){
  list <- c(list,"indel")
}
if("snp" %in% all_args){
  list <- c(list,"snp")
}


for(type in list){  # 这里必须是先 indel 再 snp！！！！
  if(type == "indel"){
    input <- df_indel
  }else if(type == "snp"){
    input <- df_snp
    }
  print(input)
  df <- read.table(input,header = T, sep = "\t")
  df <- df[grep("scaff",df$chromosome,invert = T),]  #  删除 scaffold
  df <- data.frame(SNP=df$chromosome,df)  # 随意添加第一列 画图用不到 但格式要正确
  Before <- which(colnames(df) == "Func.refGene")

  df <- df[,c(1,2,3,7:(Before-1))]
  TYPE <- toupper(type) # 大写type 放在图中
  for(sample_col in 4:length(df)){
    data <- df[grep("(\\./\\.|0/0)",df[,sample_col],invert = T),]  #  删除所有 0/0 ./. 的数据
    name <- sub("\\.","-",colnames(df)[sample_col])
    data <- data.frame(data[,1:3],data[sample_col])
    colnames(data)[4] <- colnames(df[sample_col])
    Main <- paste("The number of ",TYPE," within 1 Mb window size",sep = "")
    sample <- sub("\\.",'-',colnames(data)[4])
    outfile = paste(output,"/",TYPE,"_Density_",sample,sep="")
    # 需要生成pdf 可以直接取消注释
    # pdf(file=paste(outfile,".pdf",sep=""),width = 9,height = 6)
    # CMplot(data,
    #        type="p",
    #        plot.type="d",
    #        bin.size=1e6,
    #        chr.den.col=c("grey", "black"),
    #        file="pdf",
    #        memo="",  # 输出文件名添加内容
    #        dpi=450,
    #        file.output=F,
    #        verbose=TRUE,
    #        width=9,
    #        height=6,
    #        main = Main)  # 修改标题
    # dev.off()
    
    png(file=paste(outfile,".png",sep=""),width = 900,height = 600)
    CMplot(data,type="p",
           plot.type="d",
           bin.size=1e6,
           chr.den.col=c("grey", "black"),
           file="pdf",
           memo="",  # 输出文件名添加内容
           dpi=450,
           file.output=F,
           verbose=TRUE,
           width=9,
           height=6,
           main = Main)  # 修改标题
    dev.off()
  }
}
