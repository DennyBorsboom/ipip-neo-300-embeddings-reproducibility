source(file.path(getOption('personality.root'),'analysis','common.R'))
items<-read.csv(rp('inputs','items.csv'));m<-readRDS(rp('results','raw','matrices.rds'))
idx<-which(upper.tri(m[[1]]),arr.ind=TRUE);ii<-idx[,1];jj<-idx[,2];M<-nrow(idx)
edges<-data.frame(edge=1:M,i=ii,j=jj,id_i=items$id[ii],id_j=items$id[jj],text_i=items$text[ii],text_j=items$text[jj],same_domain=items$domain[ii]==items$domain[jj],same_facet=items$facet[ii]==items$facet[jj],same_key=items$key[ii]==items$key[jj])
for(n in names(m))edges[[n]]<-uv(m[[n]])
wc(edges,rp('results','processed','edges.csv'))
scores<-list(cosine=uv(m$semantic_cosine),partial=uv(m$semantic_partial))
emp<-list(cor=uv(m$empirical_cor),pcor=uv(m$empirical_pcor))
boot<-read.csv(rp('results','processed','bootstrap_metrics.csv'))
ci<-function(kind,metric)quantile(boot[boot$network==kind,metric],c(.025,.975),na.rm=TRUE)
out<-list();o<-1
for(kind in names(emp))for(n in c('cosine','partial')) {
 lim<-ci(kind,paste0('r_',n))
 out[[o]]<-data.frame(network=kind,semantic=n,r=cor(scores[[n]],emp[[kind]]),r_lower=lim[1],r_upper=lim[2],spearman=cor(scores[[n]],emp[[kind]],method='spearman'),magnitude_r=cor(abs(scores[[n]]),abs(emp[[kind]])),pairs=M);o<-o+1
}
primary<-do.call(rbind,out);rownames(primary)<-NULL
primary$source_N<-20993L;primary$complete_N<-7325L;primary$items<-300L;primary$participant_bootstraps<-500L
for(row in 1:nrow(primary)) {
 z<-primary[row,];v<-boot[boot$network==z$network,paste0('r_',z$semantic)]
 primary$r_bootstrap_mean[row]<-mean(v);primary$r_bootstrap_bias[row]<-mean(v)-z$r;primary$r_bootstrap_sd[row]<-sd(v)
 mag<-boot[boot$network==z$network,paste0('magnitude_r_',z$semantic)]
 primary$magnitude_r_lower[row]<-quantile(mag,.025);primary$magnitude_r_upper[row]<-quantile(mag,.975)
 primary$magnitude_r_bootstrap_mean[row]<-mean(mag);primary$magnitude_r_bootstrap_bias[row]<-mean(mag)-z$magnitude_r
 primary$magnitude_spearman[row]<-cor(abs(scores[[z$semantic]]),abs(emp[[z$network]]),method='spearman')
 primary$empirical_magnitude_r[row]<-cor(scores[[z$semantic]],abs(emp[[z$network]]))
 for(sign in c('positive','negative')) {
  use<-if(sign=='positive')emp[[z$network]]>0 else emp[[z$network]]<0
  primary[row,paste0(sign,'_n')]<-sum(use)
  primary[row,paste0(sign,'_r')]<-cor(scores[[z$semantic]][use],emp[[z$network]][use])
 }

 primary$percentile_range_contains_estimate[row]<-z$r>=z$r_lower && z$r<=z$r_upper
}
P<-getOption('personality.permutations',4999L)
normed<-function(v){v<-v-mean(v);v/sqrt(sum(v^2))}
asmat<-function(v){s<-matrix(0,300,300);s[upper.tri(s)]<-v;s+t(s)}
sn<-lapply(scores[c('cosine','partial')],function(v)asmat(normed(v)))
en<-lapply(emp,normed)
null<-matrix(NA_real_,P,4);colnames(null)<-c('r_cor_cosine','r_cor_partial','r_pcor_cosine','r_pcor_partial')
set.seed(72902)
for(b in 1:P){p<-sample.int(300);for(n in names(sn)){
 v<-uv(sn[[n]][p,p])
 for(kind in names(emp)){
  null[b,paste0('r_',kind,'_',n)]<-sum(v*en[[kind]])
 }
};if(b%%1000==0)message('QAP ',b,'/',P)}
for(row in 1:nrow(primary)){
 z<-primary[row,];primary$qap_p[row]<-(1+sum(abs(null[,paste0('r_',z$network,'_',z$semantic)])>=abs(z$r)))/(P+1)
}
wc(primary,rp('results','headline_results.csv'));saveRDS(null,rp('results','raw','qap_null.rds'))
groups<-list(all=rep(TRUE,M),same_facet=edges$same_facet,different_facet=!edges$same_facet,same_domain=edges$same_domain,different_domain=!edges$same_domain,same_key=edges$same_key,opposite_key=!edges$same_key)
regional<-list();o<-1
for(g in names(groups))for(kind in names(emp))for(n in c('cosine','partial')){use<-groups[[g]];regional[[o]]<-data.frame(group=g,n=sum(use),network=kind,semantic=n,r=cor(scores[[n]][use],emp[[kind]][use]));o<-o+1}
wc(do.call(rbind,regional),rp('results','processed','regional.csv'))
block<-paste(pmin(items$facet[ii],items$facet[jj]),pmax(items$facet[ii],items$facet[jj]),items$key[ii]*items$key[jj],sep=':')
er<-lapply(emp,function(v)normed(block_resid(v,block)));sr<-lapply(scores[c('cosine','partial')],function(v)asmat(normed(block_resid(v,block))))
observed<-unlist(lapply(names(emp),function(kind)vapply(sr,function(v)sum(uv(v)*er[[kind]]),numeric(1))));names(observed)<-c('cor_cosine','cor_partial','pcor_cosine','pcor_partial')
strata<-split(1:300,paste(items$facet,items$key));restricted<-matrix(NA_real_,P,4,dimnames=list(NULL,names(observed)));set.seed(72903)
for(b in 1:P){p<-1:300;for(s in strata)p[s]<-sample(s,length(s));for(kind in names(emp))for(n in names(sr))restricted[b,paste0(kind,'_',n)]<-sum(uv(sr[[n]][p,p])*er[[kind]])}
wc(data.frame(comparison=names(observed),r=observed,qap_p=(1+colSums(abs(restricted)>=matrix(abs(observed),P,4,byrow=TRUE)))/(P+1)),rp('results','processed','adjusted.csv'))
saveRDS(restricted,rp('results','raw','qap_restricted_null.rds'))
sens<-list();o<-1
for(target in c('empirical_cor','empirical_pcor','spearman_cor','spearman_pcor','pairwise_cor','pairwise_pcor'))for(n in c('semantic_cosine','semantic_partial','semantic_centered','semantic_ridge_0.01','semantic_ridge_0.05','semantic_ridge_0.1')){sens[[o]]<-data.frame(target=target,semantic=n,r=cor(uv(m[[target]]),uv(m[[n]])));o<-o+1}
for(kind in names(emp))for(n in c('cosine','partial')){
 d<-items$key[ii]*items$key[jj]
 for(mode in c('empirical_only_keyed','both_sign_transformed')){
  sens[[o]]<-data.frame(target=paste(kind,mode,sep='_'),semantic=n,r=cor(emp[[kind]]*d,scores[[n]]*if(mode=='both_sign_transformed')d else 1));o<-o+1
 }
}
wc(do.call(rbind,sens),rp('results','processed','specifications.csv'))
# Pair examples selected transparently by high cosine, split by empirical direction.
examples<-do.call(rbind,lapply(c('positive','negative'),function(sign){d<-edges[if(sign=='positive')edges$empirical_cor>.3 else edges$empirical_cor<(-.3),];d<-head(d[order(-d$semantic_cosine),],5);d$selection<-sign;d}))
wc(examples,rp('results','processed','example_pairs.csv'))
# Exploratory sign separation requested after visual inspection of Figure 1.
# Empirical sign is observed, not a scoring-key category; no independent-edge p-values.
branches<-list();o<-1
for(kind in names(emp))for(n in c('cosine','partial'))for(sign in c('positive','negative')) {
 use<-if(sign=='positive')emp[[kind]]>0 else emp[[kind]]<0
 v<-emp[[kind]][use];s<-scores[[n]][use]
 branches[[o]]<-data.frame(network=kind,semantic=n,branch=sign,n=sum(use),
  signed_r=cor(s,v),signed_spearman=cor(s,v,method='spearman'),
  empirical_magnitude_r=cor(s,abs(v)),magnitude_r=cor(abs(s),abs(v)),
  strength_x_signed_y_r=cor(abs(s),v),slope=unname(coef(lm(v~s))[2]),zero_excluded=sum(emp[[kind]]==0));o<-o+1
}
wc(do.call(rbind,branches),rp('results','processed','sign_branch_results.csv'))
# Exploratory display curves. Fractional response: bounded mean of |r|.
# All 44,850 pairs receive equal weight. No independent-pair inference is used.
curve_parameters<-list();curve_predictions<-list();o<-1
for(kind in c('cor','pcor')) {
 sem<-if(kind=='cor')'cosine' else 'partial'
 x<-abs(scores[[sem]]);v<-emp[[kind]]
 for(group in c('pooled','positive','negative')) {
  use<-if(group=='pooled')rep(TRUE,M) else if(group=='positive')v>0 else v<0
  df<-data.frame(x=x[use],y=abs(v[use]))
  fit<-glm(y~x+I(x^2),data=df,family=quasibinomial(link='logit'))
  stopifnot(fit$converged)
  grid<-data.frame(x=seq(min(df$x),max(df$x),length.out=501))
  curve_parameters[[o]]<-data.frame(network=kind,semantic=sem,group=group,n=sum(use),
   intercept=unname(coef(fit)[1]),linear=unname(coef(fit)[2]),quadratic=unname(coef(fit)[3]),
   x_min=min(df$x),x_max=max(df$x),converged=fit$converged,
   rmse=sqrt(mean((df$y-fitted(fit))^2)))
  grid$mean_absolute_correlation<-predict(fit,grid,type='response')
  grid$display_y<-grid$mean_absolute_correlation*if(group=='negative')-1 else 1
  grid$network<-kind;grid$semantic<-sem;grid$group<-group
  curve_predictions[[o]]<-grid;o<-o+1
 }
}
wc(do.call(rbind,curve_parameters),rp('results','processed','display_curve_parameters.csv'))
wc(do.call(rbind,curve_predictions),rp('results','processed','display_curve_predictions.csv'))
message('Matrix correlations, sign branches and bounded quadratic display curves saved')
