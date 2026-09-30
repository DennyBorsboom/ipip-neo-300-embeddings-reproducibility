source(file.path(getOption('personality.root'),'analysis','common.R'))
library(ggplot2);library(patchwork)
items<-read.csv(rp('inputs','items.csv'));edges<-read.csv(rp('results','processed','edges.csv'));h<-read.csv(rp('results','headline_results.csv'));m<-readRDS(rp('results','raw','matrices.rds'))
theme_set(theme_minimal(base_size=12)+theme(panel.grid.minor=element_blank(),plot.title=element_text(face='bold',color='#19314E'),plot.subtitle=element_text(color='#5B6168'),legend.position='bottom'))
savefig<-function(p,name,w,height){ggsave(rp('figures',paste0(name,'.png')),p,width=w,height=height,dpi=240,bg='white');ggsave(rp('figures',paste0(name,'.pdf')),p,width=w,height=height,device='pdf',bg='white')}
# Matched comparisons only. Figure 2 retains the empirical sign; Figure 1 folds it.
branch_colors<-c(Positive='#24756D',Negative='#B45941',Zero='grey60')
curves<-read.csv(rp('results','processed','display_curve_predictions.csv'))
branches<-read.csv(rp('results','processed','sign_branch_results.csv'))
plots<-list();bp<-list()
for(k in 1:2) {
 kind<-c('cor','pcor')[k];sem<-c('cosine','partial')[k]
 xcol<-paste0('semantic_',sem);ycol<-paste0('empirical_',kind)
 z<-h[h$network==kind & h$semantic==sem,]
 d<-edges;d$embedding_strength<-abs(d[[xcol]]);d$empirical_strength<-abs(d[[ycol]])
 d$empirical_sign<-factor(ifelse(d[[ycol]]>0,'Positive',ifelse(d[[ycol]]<0,'Negative','Zero')),levels=c('Positive','Negative','Zero'))
 cg<-curves[curves$network==kind & curves$group=='pooled',]
 xlabel<-if(kind=='cor')'Embedding correlation (cosine)' else 'Absolute partial embedding correlation'
 title<-paste(LETTERS[k],if(kind=='cor')'Zero-order vs. zero-order' else 'Partial vs. partial')
 plots[[k]]<-ggplot(d,aes(embedding_strength,empirical_strength))+
  geom_point(aes(color=empirical_sign),alpha=.12,size=.3)+
  geom_line(data=cg,aes(x,mean_absolute_correlation),inherit.aes=FALSE,color='#19314E',linewidth=.8)+
  scale_color_manual(values=branch_colors,name='Empirical correlation sign')+
  scale_x_continuous(limits=c(0,1),breaks=seq(0,1,.2),expand=expansion(mult=0))+
  scale_y_continuous(limits=c(0,1),breaks=seq(0,1,.2),expand=expansion(mult=c(0,.025)))+
  labs(title=title,subtitle=sprintf('Pearson r = %.3f   |   Spearman r = %.3f',z$magnitude_r,z$magnitude_spearman),
       x=xlabel,y=if(kind=='cor')'Absolute empirical correlation' else 'Absolute empirical partial correlation')
 z<-branches[branches$network==kind & branches$semantic==sem,]
 pos<-z[z$branch=='positive',];neg<-z[z$branch=='negative',]
 cg<-curves[curves$network==kind & curves$group!='pooled',]
 cg$empirical_sign<-factor(ifelse(cg$group=='positive','Positive','Negative'),levels=c('Positive','Negative','Zero'))
 bp[[k]]<-ggplot(d,aes(embedding_strength,.data[[ycol]],color=empirical_sign))+
  geom_hline(yintercept=0,color='grey65',linewidth=.3)+geom_point(alpha=.14,size=.35)+
  geom_line(data=cg,aes(x,display_y,color=empirical_sign),inherit.aes=FALSE,linewidth=.9)+
  scale_color_manual(values=branch_colors,name='Empirical correlation sign')+
  scale_x_continuous(limits=c(0,1),breaks=seq(0,1,.2),expand=expansion(mult=0))+
  scale_y_continuous(limits=c(-1,1),breaks=seq(-1,1,.5),expand=expansion(mult=0))+
  labs(title=title,subtitle=sprintf('Positive: r = %.3f (n = %s)\nNegative: r = %.3f (n = %s)',
       pos$strength_x_signed_y_r,format(pos$n,big.mark=','),neg$strength_x_signed_y_r,format(neg$n,big.mark=',')),
       x=xlabel,y=if(kind=='cor')'Signed empirical correlation' else 'Signed empirical partial correlation')
}
savefig(wrap_plots(plots,ncol=2,guides='collect')+plot_annotation(
 title='Embedding correlations and empirical association strength',
 subtitle='All 44,850 pairs | absolute correlations | bounded quadratic trend curves'),
 'figure_1_scatterplots',11,5.8)
savefig(wrap_plots(bp,ncol=2,guides='collect')+plot_annotation(
 title='Positive and negative empirical associations diverge',
 subtitle='Same embedding magnitudes as Figure 1 | separate curves by empirical sign'),
 'figure_2_signed_branches',11,6.2)

# Geometry is specified once; no graph-specific layout optimization is used.
domains<-c('N','E','O','A','C');domain_names<-c(N='Neuroticism',E='Extraversion',O='Openness',A='Agreeableness',C='Conscientiousness')
palette<-c(N='#9D4A48',E='#C19335',O='#4F8A76',A='#5382A2',C='#8871A3')
layout<-items;layout$x<-layout$y<-NA_real_
centers<-data.frame(domain=domains,angle=pi/2-(0:4)*2*pi/5)
centers$x<-1.15*cos(centers$angle);centers$y<-1.15*sin(centers$angle)
for(d in domains)for(f in 1:6){ix<-which(items$facet==paste0(d,f));ctr<-centers[centers$domain==d,];a<-pi/2-(f-1)*2*pi/6;center<-c(ctr$x+.34*cos(a),ctr$y+.34*sin(a));t<-seq(0,2*pi,length.out=11)[1:10];layout$x[ix]<-center[1]+.10*cos(t);layout$y[ix]<-center[2]+.10*sin(t)}
wc(layout,rp('results','processed','network_layout.csv'))
names4<-c('empirical_cor','semantic_cosine','empirical_pcor','semantic_partial')
titles4<-c('A  Empirical correlations','B  Embedding correlations','C  Empirical partial correlations','D  Partial embedding correlations')
np<-list();display<-list();nshow<-ceiling(.01*nrow(edges))
for(k in seq_along(names4)){
 n<-names4[k];d<-edges[head(order(-abs(edges[[n]]),edges$edge),nshow),c('edge','i','j')];d$weight<-uv(m[[n]])[d$edge]
 d$x<-layout$x[d$i];d$y<-layout$y[d$i];d$xend<-layout$x[d$j];d$yend<-layout$y[d$j];d$sign<-ifelse(d$weight>0,'Positive','Negative');d$network<-n;display[[k]]<-d
 labels<-centers;labels$y<-labels$y+.56;labels$label<-domain_names[labels$domain]
 np[[k]]<-ggplot()+geom_segment(data=d,aes(x=x,y=y,xend=xend,yend=yend,color=sign,linewidth=abs(weight)),alpha=.50)+scale_linewidth_continuous(limits=c(0,1),range=c(0,2),guide='none')+scale_color_manual(values=c(Positive='#21756C',Negative='#B34D40'),limits=c('Positive','Negative'),drop=FALSE,name='Edge sign')+geom_point(data=layout,aes(x=x,y=y,fill=domain),shape=21,size=1.2,stroke=.15,color='white')+scale_fill_manual(values=palette,guide='none')+geom_label(data=labels,aes(x=x,y=y,label=label),size=3.2,fontface='bold',color='#19314E',fill='white',linewidth=0,label.padding=unit(.12,'lines'))+coord_equal(xlim=c(-1.98,1.98),ylim=c(-1.83,1.87),clip='off')+labs(title=titles4[k],subtitle=sprintf('Strongest %s edges shown; minimum |weight| = %.3f',nshow,min(abs(d$weight))))+theme_void(base_size=12)+theme(plot.title=element_text(face='bold',color='#19314E'),plot.subtitle=element_text(size=9,color='#5B6168'),legend.position='bottom')
}
for(k in 2:4)np[[k]]<-np[[k]]+guides(color='none')
wc(do.call(rbind,display),rp('results','processed','network_display_edges.csv'))
network_plot<-wrap_plots(np,ncol=2,guides='collect')+plot_annotation(title='The same 300 items in identical positions',subtitle='Fixed domain and facet groups | 1% of edges per panel | shared absolute edge-width scale')
savefig(network_plot,'figure_3_shared_layout_networks',12,11)
for(k in 1:4)savefig(np[[k]],paste0('network_',names4[k]),10,9)

# All edges, unthresholded, with identical domain/facet ordering and color range.
ord<-order(match(items$domain,domains),items$facet,items$number);hp<-list()
for(k in 1:4){v<-m[[names4[k]]][ord,ord];diag(v)<-NA;d<-expand.grid(i=1:300,j=1:300);d$value<-as.vector(v);hp[[k]]<-ggplot(d,aes(i,j,fill=value))+geom_raster()+scale_fill_gradient2(low='#B34D40',mid='white',high='#21756C',limits=c(-1,1),name='Weight',na.value='grey90')+coord_equal()+scale_x_continuous(breaks=seq(30,270,60),labels=domains)+scale_y_reverse(breaks=seq(30,270,60),labels=domains)+geom_vline(xintercept=seq(60.5,240.5,60),color='grey60',linewidth=.2)+geom_hline(yintercept=seq(60.5,240.5,60),color='grey60',linewidth=.2)+labs(title=titles4[k],x=NULL,y=NULL)+theme(panel.grid=element_blank())}
savefig(wrap_plots(hp,ncol=2,guides='collect')+plot_annotation(title='All 44,850 item pairs, without display filtering'),'figure_4_full_matrices',10,9.5)
message('Figures created from saved edge data and one shared layout')
