#' @importFrom maxLik maxLik
#' @importFrom Matrix Matrix

cloglog <- function(...) {

  link <- function(mu) {log(-log(1 - mu))}
  inv_link <- function(eta) {1 - exp(-exp(eta))}
  dlink <- function(mu) {1 / ((mu - 1) * log(1 - mu))}

  log_like <- function(X_nons, X_rand, weights, ...) {

    function(theta) {
      eta1 <- as.matrix(X_nons) %*% theta #linear predictor
      eta2 <- as.matrix(X_rand) %*% theta
      invLink1 <- inv_link(eta1)
      invLink2 <- inv_link(eta2)

      log_like1 <- sum(log(invLink1 / (1 - invLink1)))
      log_like2 <- sum(weights * log(1 - invLink2))
      log_like1 + log_like2
    }
  }


  gradient <- function(X_nons, X_rand, weights, ...) {

    function(theta) {
      eta1 <- as.matrix(X_nons) %*% theta
      eta2 <- as.matrix(X_rand) %*% theta
      invLink1 <- inv_link(eta1)
      invLink2 <- inv_link(eta2)

      t(t(X_nons) %*% (exp(eta1)/invLink1) - t(X_rand) %*% (weights * exp(eta2)))
    }
  }


  hessian <-  function(X_nons, X_rand, weights, ...) {

    function(theta) {

      eta1 <- as.matrix(X_nons) %*% theta
      eta2 <- as.matrix(X_rand) %*% theta
      invLink1 <- inv_link(eta1)
      invLink2 <- inv_link(eta2)

      t(as.data.frame(X_nons) * (exp(eta1)/(invLink1) * (1 - exp(eta1)/invLink1 + exp(eta1)))) %*% as.matrix(X_nons) - t(as.data.frame(X_rand) * weights * exp(eta2)) %*% as.matrix(X_rand)

    }
  }


  ps_est <- function(X, log_like, gradient, hessian, start, optim_method) {

    maxLik_an <- maxLik::maxLik(logLik = log_like,
                                grad = gradient,
                                hess = hessian,
                                method = optim_method,
                                start = rep(0, length(start)))

    cloglog_estim <- maxLik_an$estimate
    grad <- maxLik_an$gradient
    hess <- maxLik_an$hessian
    estim_ps <- inv_link(cloglog_estim %*% t(as.matrix(X)))


    list(ps = estim_ps,
         grad = grad,
         hess = hess,
         theta_hat = cloglog_estim)
  }


  variance_covariance1 <- function(X, y, mu, ps, pop_size, est_method, h) {

    N <- pop_size
    if (est_method == "mle") {
      if (is.null(N)) {
        N <- sum(1/ps)
        v11 <- 1/N^2 * sum((((1 - ps)/ps^2) * (y - mu)^2))
        v1_ <- - 1/N^2 * ((1 - ps)/ps^2 * log(1 - ps) * (y - mu)) %*% X
        v_1 <- t(v1_)
      } else {
        v11 <- 1/N^2 * sum((((1 - ps)/ps^2) * y^2))
        v1_ <- - 1/N^2 * ((1 - ps)/ps^2 * log(1 - ps) * y) %*% X
        v_1 <- t(v1_)
      }

      v_2 <- 0
      for (i in 1:nrow(X)) {
        v_2i <- (1 - ps[i])/ps[i]^2 * log(1-ps[i])^2 * X[i,] %*% t(X[i,])
        v_2 <- v_2 + v_2i
      }
      v_2 <- 1/N^2 * v_2
    } else if (est_method == "ee" && h == "1") {
      if (is.null(N)) {
        N <- sum(1/ps)
        v11 <- 1/N^2 * sum(((1 - ps)/ps^2 * (y - mu)^2))
        v1_ <- 1/N^2 * ((1 - ps)/ps^2 * (y - mu)) %*% X
        v_1 <- t(v1_)
      } else {
        v11 <- 1/N^2 * sum(((1 - ps)/ps^2 * y^2))
        v1_ <- 1/N^2 * ((1 - ps)/ps * y) %*% X
        v_1 <- t(v1_)
      }

      v_2 <- 0
      for(i in 1:nrow(X)){
        v_2i <- (1 - ps[i])/ps[i] * X[i,] %*% t(X[i,])
        v_2 <- v_2 + v_2i
      }
    } else if (est_method == "ee" && h == "2") {
      if (is.null(N)) {
        N <- sum(1/ps)
        v11 <- 1/N^2 * sum(((1 - ps)/ps^2 * (y - mu)^2))
        v1_ <- 1/N^2 * ((1 - ps)/ps * (y - mu)) %*% X
        v_1 <- t(v1_)
      } else {
        v11 <- 1/N^2 * sum(((1 - ps)/ps^2 * y^2))
        v1_ <- 1/N^2 * ((1 - ps)/ps * y) %*% X
        v_1 <- t(v1_)
      }

      v_2 <- 0
      for(i in 1:nrow(X)){
        v_2i <- (1 - ps[i]) * X[i,] %*% t(X[i,])
        v_2 <- v_2 + v_2i
      }
    }

    v_2 <- 1/N^2 * v_2
    v1_vec <- cbind(v11, v1_)
    v2_mx <- cbind(v_1, v_2)
    V1 <- Matrix(rbind(v1_vec, v2_mx), sparse = TRUE)
    V1
  }

  variance_covariance2 <- function(X, eps, ps, n, N, est_method, h) {

    if (est_method == "mle") {
      s <- log(1 - eps) * as.data.frame(X)
      ci <- n/(n-1) * (1 - ps)
      B_hat <- (t(as.matrix(ci)) %*% as.matrix(s/ps))/sum(ci)
      ei <- (s/ps) - B_hat
      db_var <- t(as.matrix(ei * ci)) %*% as.matrix(ei)
      #D.var <- b %*% D %*% t(b)
    } else if (est_method == "ee"){
      if (h == "1"){
        s <- as.data.frame(X)
        ci <- n/(n-1) * (1 - ps)
        B_hat <- (t(as.matrix(ci)) %*% as.matrix(s/ps))/sum(ci)
        ei <- (s/ps) - B_hat
        db_var <- t(as.matrix(ei * ci)) %*% as.matrix(ei)
      } else if (h == "2") {
        s <- eps * as.data.frame(X)
        ci <- n/(n-1) * (1 - ps)
        B_hat <- (t(as.matrix(ci)) %*% as.matrix(s/ps))/sum(ci)
        ei <- (s/ps) - B_hat
        db_var <- t(as.matrix(ei * ci)) %*% as.matrix(ei)
      }
    }

    D <- 1/N^2 * db_var
    p <- nrow(D) + 1
    V2 <- Matrix(nrow = p, ncol = p, data = 0, sparse = TRUE)
    V2[2:p,2:p] <- D
    V2
  }

  UTB <- function(X, R, weights, ps, eta_pi, mu_der, res, psd) {

    n <- length(R)
    R_rand <- 1 - R

    utb <- c(apply(X * R/ps * mu_der - X * R_rand * weights * mu_der, 2, sum),
             apply(X * R * (1-ps)/ps^2 * as.vector(exp(eta_pi)) * res, 2, sum))/n
    utb

  }

  structure(
    list(
      make_log_like = log_like,
      make_gradient = gradient,
      make_hessian = hessian,
      make_link_fun = link,
      make_link_inv = inv_link,
      make_link_der = dlink,
      make_propen_score = ps_est,
      variance_covariance1 = variance_covariance1,
      variance_covariance2 = variance_covariance2,
      UTB = UTB
    ),

    class = "method_selection"
  )

}
