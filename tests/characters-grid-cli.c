#include <complex.h>
#include <math.h>
#include <stdio.h>
#include "../code/characters.h"

/* Independent C11 FFI oracle for generated-character JS numerical tests.
   Input: modulus index mode cutoff prime Re(s) Im(s).
   mode 0 evaluates chi(cutoff); 1 finite sum; 2 local; 3 product.
   Output: denominator value-order conductor parity Re(value) Im(value). */
int main(void) {
    unsigned q,index,mode,cutoff,p;
    double real_part,imag_part;
    while (scanf("%u %u %u %u %u %lf %lf",
                 &q,&index,&mode,&cutoff,&p,&real_part,&imag_part)==7) {
        struct dirichlet_character c;
        if (!dirichlet_characters_generate(q,index,&c)) return 2;
        double complex s=CMPLX(real_part,imag_part);
        double complex z;
        switch (mode) {
            case 0: z=dirichlet_characters_value(&c,cutoff); break;
            case 1: z=dirichlet_characters_partial_sum(&c,cutoff,s); break;
            case 2: z=dirichlet_characters_local_factor(&c,p,s); break;
            case 3: z=dirichlet_characters_finite_product(&c,cutoff,s); break;
            default: return 3;
        }
        if (!isfinite(creal(z)) || !isfinite(cimag(z))) return 4;
        printf("%u %u %u %u %.17g %.17g\n",
               c.phase_denominator,c.value_order,c.conductor,c.parity,
               creal(z),cimag(z));
    }
    if (ferror(stdin)) return 5;
    return 0;
}
