source(file.path(getOption('personality.root'),'analysis','common.R'))
fits<-readRDS(rp('results','raw','bootnet_fits.rds'))
mat<-readRDS(rp('results','raw','matrices.rds'))
scores<-list(cosine=uv(mat$semantic_cosine),partial=uv(mat$semantic_partial))
B<-getOption('personality.B',500L);cores<-getOption('personality.cores',4L);chunk<-50L
all_metrics<-list()
for(kind in c('cor','pcor')) {
 for(start in seq(1,B,by=chunk)) {
  count<-min(chunk,B-start+1);path<-rp('results','raw',sprintf('bootstrap_%s_%04d.rds',kind,start))
  if(file.exists(path)) {message('Using checkpoint ',basename(path));next}
  set.seed(72901L+start)
  message('bootnet ',kind,' bootstrap ',start,'-',start+count-1,'/',B)
  obj<-capture(bootnet::bootnet(fits[[paste0('empirical_',kind)]],nBoots=count,type='nonparametric',nCores=cores,statistics='edge',computeCentrality=FALSE,verbose=FALSE,memorysaver=TRUE))
  stopifnot(length(obj$value$boots)==count)
  edges<-vapply(obj$value$boots,function(f)uv(f$graph),numeric(44850))
  metrics<-t(apply(edges,2,metric_vec,scores=scores))
  saveRDS(list(edges=edges,metrics=metrics,kind=kind,seed=72901L+start,warnings=obj$warnings,replicates=start:(start+count-1),n=nrow(fits[[paste0('empirical_',kind)]]$data)),path,compress='gzip')
  rm(obj,edges);gc()
 }
 files<-list.files(rp('results','raw'),pattern=paste0('^bootstrap_',kind,'_[0-9]+.rds$'),full.names=TRUE)
 chunks<-lapply(files,readRDS);edges<-do.call(cbind,lapply(chunks,`[[`,'edges'));edges<-edges[,seq_len(B),drop=FALSE]
 metrics<-t(apply(edges,2,metric_vec,scores=scores))
 all_metrics[[kind]]<-data.frame(network=kind,replicate=1:B,metrics)
 intervals<-t(apply(edges,1,quantile,probs=c(.025,.975)))
 wc(data.frame(edge=1:44850,estimate=uv(mat[[paste0('empirical_',kind)]]),lower=intervals[,1],upper=intervals[,2]),rp('results','processed',paste0('edge_uncertainty_',kind,'.csv')))
 rm(chunks,edges);gc()
}
wc(do.call(rbind,all_metrics),rp('results','processed','bootstrap_metrics.csv'))
message('Bootnet participant resampling complete')
