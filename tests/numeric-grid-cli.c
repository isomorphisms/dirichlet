#include <complex.h>
#include <math.h>
#include <stdio.h>
#include "../code/dirichlet_eval.h"
#include "../code/characters.h"

/* Separate C11 evaluator, not a mechanical translation of the JS source.
   Stdin: model cutoff prime character generated_modulus generated_index Re(s) Im(s).
   Stdout: Re(f) Im(f), one row per case. */
int main(void) {
    int model;
    unsigned cutoff, prime, character, modulus, index;
    double real_part, imaginary_part;
    while (scanf("%d %u %u %u %u %u %lf %lf",
                 &model, &cutoff, &prime, &character, &modulus, &index,
                 &real_part, &imaginary_part) == 8) {
        double complex z = CMPLX(real_part, imaginary_part);
        double complex value;
        if (modulus != 0u) {
            struct dirichlet_character generated;
            if (!dirichlet_characters_generate(modulus,index,&generated)) return 2;
            switch (model) {
                case 1: value = dirichlet_characters_local_factor(&generated,prime,z); break;
                case 2: value = dirichlet_characters_partial_sum(&generated,cutoff,z); break;
                case 3: value = dirichlet_characters_finite_product(&generated,cutoff,z); break;
                default: return 3;
            }
        } else {
            switch (model) {
                case 0: value = dirichlet_geometric(cutoff, z); break;
                case 1: value = dirichlet_character_local_factor(character,prime,z); break;
                case 2: value = dirichlet_character_partial_sum(character,cutoff,z); break;
                case 3: value = dirichlet_character_finite_euler_product(character,cutoff,z); break;
                default: return 3;
            }
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
