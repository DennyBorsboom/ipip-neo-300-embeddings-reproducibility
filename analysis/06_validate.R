source(file.path(getOption('personality.root'),'analysis','common.R'))
items<-read.csv(rp('inputs','items.csv'));m<-readRDS(rp('results','raw','matrices.rds'));x<-readRDS(rp('results','raw','complete_responses.rds'));e<-readRDS(rp('inputs','jina_embeddings.rds'));h<-read.csv(rp('results','headline_results.csv'));d<-read.csv(rp('results','processed','edges.csv'))
checks<-list();add<-function(name,value,pass)checks[[length(checks)+1]]<<-data.frame(check=name,value=as.character(value),pass=pass)
add('300 unique item ids',length(unique(items$id)),length(unique(items$id))==300)
add('44850 unique pairs',nrow(d),nrow(d)==44850 && !anyDuplicated(paste(d$i,d$j)))
add('complete cases',nrow(x),nrow(x)==7325)
r<-cor(x);diag(r)<-0;delta<-max(abs(r-m$empirical_cor));add('bootnet correlation versus independent cor',delta,delta<1e-10)
rr<-cor(x);precision<-solve(rr);p<--precision/sqrt(outer(diag(precision),diag(precision)));diag(p)<-0;delta<-max(abs(p-m$empirical_pcor));add('bootnet partial versus independent solve',delta,delta<1e-8)
for(n in names(m)){add(paste(n,'symmetric'),max(abs(m[[n]]-t(m[[n]]))),max(abs(m[[n]]-t(m[[n]])))<1e-10);add(paste(n,'finite'),sum(!is.finite(m[[n]])),all(is.finite(m[[n]])))}
s<-cosmat(e);dS<-max(abs(uv(s)-uv(m$semantic_cosine)));add('frozen embeddings reproduce cosine',dS,dS<1e-10)
for(pair in list(c(1,31),c(2,212),c(9,99))){keep<-setdiff(1:300,pair);u<-e/sqrt(rowSums(e^2));q<-qr(t(u[keep,]));a<-qr.resid(q,u[pair[1],]);b<-qr.resid(q,u[pair[2],]);res<-sum(a*b)/sqrt(sum(a*a)*sum(b*b));delta<-abs(res-m$semantic_partial[pair[1],pair[2]]);add(paste('residual cosine',paste(pair,collapse=':')),delta,delta<1e-8)}
for(i in 1:nrow(h)){z<-h[i,];v<-uv(m[[paste0('empirical_',z$network)]]);s<-uv(m[[if(z$semantic=='cosine')'semantic_cosine' else 'semantic_partial']]);add(paste('headline r',z$network,z$semantic),cor(v,s),abs(cor(v,s)-z$r)<1e-10)

}
q<-read.csv(rp('inputs','questionnaire_wording_check.csv'));q<-q[match(items$number,q$number),];normalize<-function(t)tolower(gsub('[^[:alnum:]]','',t));delta<-sum(normalize(q$text)!=normalize(items$text));add('wording agrees with author questionnaire',delta,delta==0)
key2<-readxl::read_excel(rp('inputs','IPIP-NEO-300_scoring.xlsx'),sheet='Input',range='A1:E301');key2<-key2[order(as.numeric(key2[[1]])),];delta<-sum(as.character(key2[[2]])!=paste0(ifelse(items$key>0,'+','-'),items$facet));add('independent scoring workbook keys',delta,delta==0)
layout<-read.csv(rp('results','processed','network_layout.csv'));display<-read.csv(rp('results','processed','network_display_edges.csv'));delta<-max(abs(display$x-layout$x[display$i]),abs(display$y-layout$y[display$i]),abs(display$xend-layout$x[display$j]),abs(display$yend-layout$y[display$j]));add('every panel uses identical saved positions',delta,delta<1e-12)
b<-read.csv(rp('results','processed','bootstrap_metrics.csv'));counts<-table(b$network);add('500 bootstrap replicates per empirical network',paste(counts,collapse=','),all(counts==500))
# Independently verify magnitude summaries and outcome-sign partitions.
for(i in seq_len(nrow(h))) {
 z<-h[i,];v<-uv(m[[paste0('empirical_',z$network)]]);s<-uv(m[[paste0('semantic_',z$semantic)]])
 check_r<-cov(abs(v),abs(s))/(sd(abs(v))*sd(abs(s)))
 add(paste('magnitude alignment',z$network,z$semantic),check_r,abs(check_r-z$magnitude_r)<1e-10)
 raw_mag<-cor(s,abs(v));add(paste('raw semantic versus empirical magnitude',z$network,z$semantic),raw_mag,abs(raw_mag-z$empirical_magnitude_r)<1e-10)
 bv<-b[b$network==z$network,paste0('magnitude_r_',z$semantic)];q<-quantile(bv,c(.025,.975))
 delta<-max(abs(q-c(z$magnitude_r_lower,z$magnitude_r_upper)));add(paste('magnitude resampling range',z$network,z$semantic),delta,delta<1e-10)
}
sb<-read.csv(rp('results','processed','sign_branch_results.csv'))
for(i in seq_len(nrow(sb))) {
 z<-sb[i,];v<-uv(m[[paste0('empirical_',z$network)]]);s<-uv(m[[paste0('semantic_',z$semantic)]])
 use<-if(z$branch=='positive')v>0 else v<0
 rr<-unname(coef(lm(v[use]~s[use]))[2])*sd(s[use])/sd(v[use])
 add(paste('sign branch count and correlation',z$network,z$semantic,z$branch),paste(sum(use),format(rr)),sum(use)==z$n && abs(rr-z$signed_r)<1e-10 && abs(cor(abs(s[use]),v[use])-z$strength_x_signed_y_r)<1e-10)
}
plot_values<-unlist(d[c('semantic_cosine','semantic_partial','empirical_cor','empirical_pcor')])
add('all scatterplot observations fall within displayed unit bounds',paste(range(plot_values),collapse=','),all(is.finite(plot_values)) && all(abs(plot_values)<=1))
add('all raw cosine values are positive',min(uv(m$semantic_cosine)),min(uv(m$semantic_cosine))>0)
# Check bounds and reconstruct displayed means independently from saved coefficients.
cp<-read.csv(rp('results','processed','display_curve_parameters.csv'))
cg<-read.csv(rp('results','processed','display_curve_predictions.csv'))
add('six converged matched-comparison curves',nrow(cp),nrow(cp)==6 && all(cp$converged) &&
 all((cp$network=='cor' & cp$semantic=='cosine') | (cp$network=='pcor' & cp$semantic=='partial')))
for(i in seq_len(nrow(cp))) {
 z<-cp[i,];g<-cg[cg$network==z$network & cg$group==z$group,]
 mu<-1/(1+exp(-(z$intercept+z$linear*g$x+z$quadratic*g$x^2)))
 delta<-max(abs(mu-g$mean_absolute_correlation))
 add(paste('bounded quadratic curve',z$network,z$group),delta,
  delta<1e-10 && all(g$mean_absolute_correlation>=0 & g$mean_absolute_correlation<=1) &&
  min(g$x)>=z$x_min-1e-12 && max(g$x)<=z$x_max+1e-12 && nrow(g)==501)
}
out<-do.call(rbind,checks);wc(out,rp('results','processed','validation.csv'));if(!all(out$pass))stop('Validation failed: ',paste(out$check[!out$pass],collapse='; '));message('All ',nrow(out),' validation checks passed')
