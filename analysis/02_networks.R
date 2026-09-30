source(file.path(getOption('personality.root'),'analysis','common.R'))
items<-read.csv(rp('inputs','items.csv'));x<-readRDS(rp('results','raw','complete_responses.rds'));xa<-readRDS(rp('inputs','responses_administered.rds'));e<-readRDS(rp('inputs','jina_embeddings.rds'))
fits<-list();fits$empirical_cor<-fit_emp(x,'cor');fits$empirical_pcor<-fit_emp(x,'pcor')
s<-cosmat(e);ev<-eigen(s,symmetric=TRUE,only.values=TRUE)$values
ridge<-if(min(ev)<=1e-8).01 else 0
fits$semantic_cosine<-fit_sem(e)
fits$semantic_partial<-fit_sem(e,'partial',ridge)
for(l in c(.01,.05,.10)) fits[[paste0('semantic_ridge_',l)]]<-fit_sem(e,'partial',l)
ec<-e-rowMeans(e);fits$semantic_centered<-fit_sem(ec)
for(kind in c('cor','pcor')) {
 fits[[paste0('spearman_',kind)]]<-fit_emp(x,kind,'spearman')
 fits[[paste0('pairwise_',kind)]]<-fit_emp(xa,kind,missing='pairwise')
}
saveRDS(fits,rp('results','raw','bootnet_fits.rds'),compress='gzip')
matrices<-lapply(fits,function(f)f$graph)
saveRDS(matrices,rp('results','raw','matrices.rds'),compress='gzip')
for(n in names(matrices))write.csv(matrices[[n]],rp('results','processed',paste0('matrix_',n,'.csv')))
wc(data.frame(semantic_min_eigenvalue=min(ev),semantic_max_eigenvalue=max(ev),semantic_condition=max(ev)/min(ev),semantic_rank=sum(ev>1e-8),primary_ridge=ridge,empirical_min_eigenvalue=min(eigen(cor(x),symmetric=TRUE,only.values=TRUE)$values)),rp('results','processed','network_diagnostics.csv'))
message('All networks saved')
