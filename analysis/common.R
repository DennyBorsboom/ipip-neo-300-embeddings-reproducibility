options(stringsAsFactors=FALSE, warn=1)
root <- getOption('personality.root', normalizePath('.'))
rp <- function(...) file.path(root,...)
wc <- function(x,path) write.csv(x,path,row.names=FALSE,na='')
uv <- function(x) as.numeric(x[upper.tri(x)])
cosmat <- function(e) {u<-e/sqrt(rowSums(e^2));s<-tcrossprod(u);diag(s)<-1;s}
partial <- function(s) {k<-chol2inv(chol(s));p<--cov2cor(k);diag(p)<-0;p}
capture <- function(expr) {w<-character();v<-withCallingHandlers(expr,warning=function(e){w<<-c(w,conditionMessage(e));invokeRestart('muffleWarning')});list(value=v,warnings=w)}
fit_emp <- function(x,kind,method='cor',missing='listwise') bootnet::estimateNetwork(x,default=kind,corMethod=method,missing=missing,threshold=0,verbose=FALSE)
semantic_estimator <- function(data,kind='cosine',ridge=0) {
 e<-t(as.matrix(data));s<-cosmat(e);s<-(1-ridge)*s+ridge*diag(nrow(s))
 g<-if(kind=='partial') partial(s) else s;diag(g)<-0
 list(graph=g,results=list(gram=s,ridge=ridge,interpretation='Deterministic embedding geometry; coordinates are not respondents'))
}
fit_sem <- function(e,kind='cosine',ridge=0) bootnet::estimateNetwork(t(e),fun=semantic_estimator,kind=kind,ridge=ridge,labels=rownames(e),verbose=FALSE)
block_resid <- function(v,block) v-ave(v,block,FUN=mean)
metric_vec <- function(v,scores) {
 out<-numeric()
 for(n in names(scores)) {
  s<-scores[[n]]
  out[paste0('r_',n)]<-cor(s,v)
  out[paste0('magnitude_r_',n)]<-cor(abs(s),abs(v))
 }
 out
}
