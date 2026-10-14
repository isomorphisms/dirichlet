#include "dirichlet_eval.h"

#include <math.h>

static double complex invalid_value(void) {
    return CMPLX(NAN, NAN);
}

int dirichlet_chi4(unsigned n) {
    if ((n & 1u) == 0u) return 0;
    return n % 4u == 1u ? 1 : -1;
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

double complex dirichlet_chi4_partial_sum(unsigned last_n, double complex s) {
    if (last_n > DIRICHLET_MAX_SERIES) return invalid_value();
    double complex total = 0.0;
    for (unsigned n = 1u; n <= last_n; ++n) {
        int character = dirichlet_chi4(n);
        if (character != 0) {
            total += (double)character * cexp(-s * log((double)n));
        }
    }
    /* Finite sum is entire; chi4 converges to L in Re(s)>0,
       absolutely in Re(s)>1. Not a continuation algorithm. */
    return total;
}

double complex dirichlet_chi4_local_factor(unsigned prime, double complex s) {
    if (prime > DIRICHLET_MAX_PRIME || !dirichlet_is_prime(prime)) {
        return invalid_value();
    }
    int character = dirichlet_chi4(prime);
    return 1.0 / (1.0 - (double)character * cexp(-s * log((double)prime)));
}

double complex dirichlet_chi4_finite_euler_product(
    unsigned last_prime,
    double complex s
) {
    if (last_prime > DIRICHLET_MAX_PRIME) return invalid_value();
    double complex total = 1.0;
    for (unsigned p = 2u; p <= last_prime; ++p) {
        if (!dirichlet_is_prime(p)) continue;
        total *= dirichlet_chi4_local_factor(p, s);
    }
    return total;
}
