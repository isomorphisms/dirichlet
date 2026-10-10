#ifndef DIRICHLET_EVAL_H
#define DIRICHLET_EVAL_H

#include <complex.h>

/* Bounded scalar and shader evaluators. */
enum {
    DIRICHLET_MAX_GEOMETRIC = 32,
    DIRICHLET_MAX_SERIES = 127,
    DIRICHLET_MAX_PRIME = 31
};

/* Fixed character catalogue; not modular-form weights or nebentypus.
   Residues have exact values 0, +1, -1, +i or -i. */
enum dirichlet_character_id {
    DIRICHLET_CHI4 = 0,        /* primitive modulo 4, odd */
    DIRICHLET_CHI3 = 1,        /* primitive modulo 3, odd */
    DIRICHLET_CHI5_PLUS = 2,  /* primitive quartic: chi(2) = +i */
    DIRICHLET_CHI5_MINUS = 3, /* complex conjugate: chi(2) = -i */
    DIRICHLET_CHI8 = 4,        /* quadratic modulo 8, even */
    DIRICHLET_CHI0_MOD4 = 5,  /* principal modulo 4 */
    DIRICHLET_CHI1 = 6,       /* principal modulo 1: zeta */
    DIRICHLET_CHARACTER_COUNT = 7
};
unsigned dirichlet_character_modulus(unsigned character);
double complex dirichlet_character_value(unsigned character, unsigned n);
/* Exhaustive finite-table axiom check; not a universal proof. */
int dirichlet_character_table_valid(unsigned character);

/* Original modulo-four public interface retained. */
int dirichlet_chi4(unsigned n);
int dirichlet_is_prime(unsigned n);
double complex dirichlet_geometric(unsigned terms, double complex q);
double complex dirichlet_chi4_partial_sum(unsigned last_n, double complex s);
double complex dirichlet_chi4_local_factor(unsigned prime, double complex s);
double complex dirichlet_chi4_finite_euler_product(unsigned last_prime, double complex s);

/* Complex-valued character expressions; all are FINITE approximants.
   Invalid character, prime or cutoff: NaN + i*NaN. */
double complex dirichlet_character_partial_sum(
    unsigned character, unsigned last_n, double complex s);
double complex dirichlet_character_local_factor(
    unsigned character, unsigned prime, double complex s);
double complex dirichlet_character_finite_euler_product(
    unsigned character, unsigned last_prime, double complex s);
#endif
