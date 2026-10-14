#include <complex.h>
#include <math.h>
#include <stdio.h>
#include "../code/dirichlet_eval.h"

/* Separate C11 evaluator, not a mechanical translation of the JS source.
   Stdin: model cutoff prime Re(s) Im(s).
   Stdout: Re(f) Im(f), one row per case. */
int main(void) {
    int model;
    unsigned cutoff, prime;
    double real_part, imaginary_part;
    while (scanf("%d %u %u %lf %lf",
                 &model, &cutoff, &prime, &real_part, &imaginary_part) == 5) {
        double complex z = CMPLX(real_part, imaginary_part);
        double complex value;
        switch (model) {
            case 0: value = dirichlet_geometric(cutoff, z); break;
            case 1: value = dirichlet_chi4_local_factor(prime, z); break;
            case 2: value = dirichlet_chi4_partial_sum(cutoff, z); break;
            case 3: value = dirichlet_chi4_finite_euler_product(cutoff, z); break;
            default: fputs("invalid model\n", stderr); return 2;
        }
        if (!isfinite(creal(value)) || !isfinite(cimag(value))) {
            fputs("nonfinite reference\n", stderr);
            return 3;
        }
        printf("%.17g %.17g\n", creal(value), cimag(value));
    }
    if (ferror(stdin)) return 4;
    return 0;
}
