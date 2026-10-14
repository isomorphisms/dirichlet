#include <assert.h>
#include <complex.h>
#include <math.h>
#include <stdio.h>

#include "../code/dirichlet_eval.h"

static int near(double complex actual, double complex expected, double tolerance) {
    return cabs(actual - expected) <= tolerance;
}

int main(void) {
    assert(dirichlet_character_valid(1));
    assert(dirichlet_character_valid(3));
    assert(dirichlet_character_valid(4));
    assert(!dirichlet_character_valid(2));
    assert(dirichlet_weight(3, 1) == 1);
    assert(dirichlet_weight(3, 2) == -1);
    assert(dirichlet_weight(3, 3) == 0);
    assert(dirichlet_weight(3, 4) == 1);
    assert(dirichlet_weight(1, 4) == 1);
    assert(dirichlet_weight(2, 1) == 2); /* sentinel, not a weight */
    assert(dirichlet_chi4(1) == 1);
    assert(dirichlet_chi4(2) == 0);
    assert(dirichlet_chi4(3) == -1);
    assert(dirichlet_chi4(5) == 1);
    assert(dirichlet_chi4(7) == -1);
    assert(!dirichlet_is_prime(1));
    assert(dirichlet_is_prime(2));
    assert(dirichlet_is_prime(3));
    assert(!dirichlet_is_prime(9));

    assert(near(dirichlet_geometric(0, 1), 0, 1e-14));
    assert(near(dirichlet_geometric(1, 1), 1, 1e-14));
    assert(near(dirichlet_geometric(4, 1), 4, 1e-14));
    assert(near(dirichlet_geometric(4, -1), 0, 1e-14));
    assert(near(dirichlet_geometric(4, I), 0, 1e-14));
    assert(near(dirichlet_geometric(4, -I), 0, 1e-14));

    double complex q = 0.25 + 0.40*I;
    double complex g = dirichlet_geometric(9, q);
    /* Finite ring identity, independent of division, including the q=1 case. */
    assert(near((1.0-q)*g, 1.0-cpow(q,9), 1e-12));
    assert(near((1.0-1.0)*dirichlet_geometric(9,1), 1.0-cpow(1.0,9), 1e-14));

    assert(near(dirichlet_weighted_local_factor(3, 2, 3), 1.0, 1e-13));
    assert(near(dirichlet_weighted_local_factor(2, 2, 3), 0.8, 1e-13));
    assert(near(dirichlet_weighted_local_factor(2, 2, 1), 4.0/3.0, 1e-13));
    assert(near(dirichlet_weighted_partial_sum(2, 2, 3), 0.75, 1e-13));
    assert(near(dirichlet_weighted_partial_sum(3, 2, 1), 49.0/36.0, 1e-13));
    assert(near(dirichlet_weighted_finite_euler_product(3, 2, 1), 1.5, 1e-13));
    assert(near(dirichlet_chi4_local_factor(3, 2), 0.9, 1e-13));
    assert(near(dirichlet_chi4_local_factor(2, 2), 1.0, 1e-13));
    assert(near(dirichlet_chi4_partial_sum(3, 2), 8.0/9.0, 1e-13));
    assert(near(dirichlet_chi4_finite_euler_product(3, 2), 0.9, 1e-13));
    assert(near(dirichlet_chi4_finite_euler_product(5, 2), 0.9375, 1e-13));
    /* Catalan's constant is an independent reference, NOT a proof of the limit. */
    assert(fabs(creal(dirichlet_chi4_partial_sum(127, 2)) -
        0.91596559417721901505) < 1e-4);
    assert(!isfinite(creal(dirichlet_geometric(33, 1))));
    assert(!isfinite(creal(dirichlet_chi4_partial_sum(128, 2))));
    assert(!isfinite(creal(dirichlet_chi4_local_factor(9, 2))));
    assert(!isfinite(creal(dirichlet_weighted_local_factor(3, 2, 2))));
    assert(!isfinite(creal(dirichlet_weighted_partial_sum(0, 2, 2))));
    assert(!isfinite(creal(dirichlet_weighted_finite_euler_product(0, 2, 2))));
    puts("Dirichlet finite evaluator: host fixtures passed");
    return 0;
}
