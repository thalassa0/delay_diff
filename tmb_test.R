# Author Fay
# initialise ----
install.packages("Rcpp")
library(Rcpp)
setwd("C:/A/R_code/TMB/tutorial")
sourceCpp("meanC.cpp") 


cppFunction('int one() {
  return 1;
}')

vignette("Rcpp-jss-2011")
vignette("Rcpp-introduction")
vignette("Rcpp-attributes")

set.seed(123)
evalCpp("Rcpp::rnorm(3)")

library("microbenchmark")
results <- microbenchmark(isOddR = isOddR(12L),
                          isOddCpp = isOddCpp(12L))
print(summary(results)[, c(1:7)],digits=1)


# example simple ----

library(Rcpp)


cppFunction('int one() {
  return 1;
}')

cppFunction('double sumC(NumericVector x) {
  int n = x.size();
  double total = 0;
  for(int i = 0; i < n; ++i) {
    total += x[i];
  }
  return total;
}')

Rscript -e 'Rcpp::Rcpp.package.skeleton("mod", path = "/tmp", module =
TRUE); 
Rcpp::compileAttributes("mod")'
R CMD build mod && R CMD check --as-cran mod_1.0.tar.gz
