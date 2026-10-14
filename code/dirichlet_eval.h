#ifndef DIRICHLET_EVAL_H
#define DIRICHLET_EVAL_H

#include <complex.h>

/* Bounded host reference: these limits are also used by web/dirichlet.frag.in. */
enum {
    DIRICHLET_MAX_GEOMETRIC = 32,
    DIRICHLET_MAX_SERIES = 127,
    DIRICHLET_MAX_PRIME = 31
};

/* Real Dirichlet characters modulo 1, 3, 4. Modulus 1 has weight 1
   for every positive integer and produces zeta's finite approximants.
   Invalid modulus/n returns sentinel 2, never a valid character value. */
int dirichlet_character_valid(unsigned modulus);
int dirichlet_weight(unsigned modulus, unsigned n);
int dirichlet_chi4(unsigned n);
int dirichlet_is_prime(unsigned n);

/* Finite identities: defined even where no infinite limit exists. */
double complex dirichlet_geometric(unsigned terms, double complex q);
double complex dirichlet_weighted_partial_sum(unsigned last_n, double complex s, unsigned modulus);
double complex dirichlet_chi4_partial_sum(unsigned last_n, double complex s);
double complex dirichlet_weighted_local_factor(unsigned prime, double complex s, unsigned modulus);
double complex dirichlet_chi4_local_factor(unsigned prime, double complex s);
double complex dirichlet_weighted_finite_euler_product(unsigned last_prime, double complex s, unsigned modulus);
double complex dirichlet_chi4_finite_euler_product(unsigned last_prime, double complex s);

/* Limits outside the stated bounds return NaN + i*NaN. No analytic
   continuation of a full L-function is provided by these approximants. */
#endif
