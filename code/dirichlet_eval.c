#include "dirichlet_eval.h"

#include <math.h>

static double complex invalid_value(void) {
    return CMPLX(NAN, NAN);
}

int dirichlet_character_valid(unsigned modulus) {
    return modulus == 1u || modulus == 3u || modulus == 4u;
}

int dirichlet_weight(unsigned modulus, unsigned n) {
    if (n == 0u || !dirichlet_character_valid(modulus)) return 2;
    if (modulus == 1u) return 1;
    if (modulus == 3u) {
        unsigned remainder = n % 3u;
        return remainder == 0u ? 0 : (remainder == 1u ? 1 : -1);
    }
    if ((n & 1u) == 0u) return 0;
    return n % 4u == 1u ? 1 : -1;
}

int dirichlet_chi4(unsigned n) {
    return dirichlet_weight(4u, n);
}

int dirichlet_is_prime(unsigned n) {
    if (n < 2u) return 0;
    for (unsigned divisor = 2u; divisor <= n / divisor; ++divisor) {
        if (n % divisor == 0u) return 0;
    }
    return 1;
}

double complex dirichlet_geometric(unsigned terms, double complex q) {
    if (terms > DIRICHLET_MAX_GEOMETRIC) return invalid_value();
    double complex total = 0.0;
    double complex power = 1.0;
    /* No division by (1-q): q=1 is a regular point with value terms. */
    for (unsigned k = 0u; k < terms; ++k) {
        total += power;
        power *= q;
    }
    return total;
}

double complex dirichlet_weighted_partial_sum(unsigned last_n, double complex s, unsigned modulus) {
    if (last_n > DIRICHLET_MAX_SERIES || !dirichlet_character_valid(modulus)) return invalid_value();
    double complex total = 0.0;
    for (unsigned n = 1u; n <= last_n; ++n) {
        int coefficient = dirichlet_weight(modulus, n);
        if (coefficient != 0) {
            total += (double)coefficient * cexp(-s * log((double)n));
        }
    }
    /* Finite sum is entire; nonprincipal chi3/chi4 infinite series
       converge for Re(s)>0, absolutely for Re(s)>1.
       Modulus 1 (zeta) only converges for Re(s)>1. */
    return total;
}

double complex dirichlet_chi4_partial_sum(unsigned last_n, double complex s) {
    return dirichlet_weighted_partial_sum(last_n, s, 4u);
}

double complex dirichlet_weighted_local_factor(unsigned prime, double complex s, unsigned modulus) {
    if (!dirichlet_character_valid(modulus) || prime > DIRICHLET_MAX_PRIME || !dirichlet_is_prime(prime)) {
        return invalid_value();
    }
    int character = dirichlet_weight(modulus, prime);
    return 1.0 / (1.0 - (double)character * cexp(-s * log((double)prime)));
}

double complex dirichlet_chi4_local_factor(unsigned prime, double complex s) {
    return dirichlet_weighted_local_factor(prime, s, 4u);
}

double complex dirichlet_weighted_finite_euler_product(
    unsigned last_prime,
    double complex s,
    unsigned modulus
) {
    if (last_prime > DIRICHLET_MAX_PRIME || !dirichlet_character_valid(modulus)) return invalid_value();
    double complex total = 1.0;
    for (unsigned p = 2u; p <= last_prime; ++p) {
        if (!dirichlet_is_prime(p)) continue;
        total *= dirichlet_weighted_local_factor(p, s, modulus);
    }
    return total;
}

double complex dirichlet_chi4_finite_euler_product(unsigned last_prime, double complex s) {
    return dirichlet_weighted_finite_euler_product(last_prime, s, 4u);
}
