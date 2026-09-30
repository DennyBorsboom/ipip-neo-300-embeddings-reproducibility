argv<-commandArgs(FALSE);entry<-sub('^--file=','',argv[grepl('^--file=',argv)][1]);root<-dirname(normalizePath(entry))
options(personality.root=root,personality.B=500L,personality.cores=4L)
args<-commandArgs(TRUE)
if('--serial'%in%args)options(personality.cores=1L)
if('--verify'%in%args){source(file.path(root,'analysis','06_validate.R'));quit(save='no')}
for(s in c('01_import.R','02_networks.R','03_bootstrap.R','04_compare.R','05_figures.R','06_validate.R'))source(file.path(root,'analysis',s))
