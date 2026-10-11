#include <assert.h>
#include <complex.h>
#include <math.h>
#include <stdio.h>
#include "../code/characters.h"
#include "../code/dirichlet_eval.h"

static unsigned gcd_u(unsigned a, unsigned b) {
    while (b) { unsigned r=a%b; a=b; b=r; }
    return a;
}
static unsigned independent_totient(unsigned q) {
    unsigned count=0u;
    for (unsigned n=0u;n<q;++n) if (gcd_u(n,q)==1u) ++count;
    return count;
}
static int near(double complex x, double complex y, double tolerance) {
    return cabs(x-y)<tolerance;
}
static struct dirichlet_character generated(unsigned q, unsigned id) {
    struct dirichlet_character result;
    assert(dirichlet_characters_generate(q,id,&result));
    assert(dirichlet_characters_verify(&result));
    return result;
}

int main(void) {
    assert(dirichlet_characters_count(0)==0);
    assert(dirichlet_characters_count(129)==0);
    assert(!dirichlet_characters_generate(0,0,NULL));
    assert(!dirichlet_characters_generate(4,2,NULL));
    assert(!dirichlet_characters_generate(4,2,&(struct dirichlet_character){0}));
    for (unsigned modulus=1u;modulus<=DIRICHLET_CHARACTER_MAX_MODULUS;++modulus) {
        unsigned count=dirichlet_characters_count(modulus);
        assert(count==independent_totient(modulus));
        struct dirichlet_character principal=generated(modulus,0);
        assert(principal.value_order==1u);
        assert(principal.conductor==1u);
        assert(principal.parity==0u);
        struct dirichlet_character catalogue[DIRICHLET_CHARACTER_MAX_MODULUS];
        for (unsigned id=0u;id<count;++id) {
            struct dirichlet_character c=generated(modulus,id);
            catalogue[id]=c;
            assert(c.modulus==modulus && c.index==id);
            assert(c.conductor>=1u && modulus%c.conductor==0u);
            assert(c.phase_denominator%c.value_order==0u);
            assert(c.parity<=1u);
            for (unsigned a=0u;a<modulus;++a) {
                double complex value=dirichlet_characters_value(&c,a);
                double complex repeat=dirichlet_characters_value(&c,a+5u*modulus);
                assert(near(value,repeat,1e-13));
                assert(fabs(cabs(value)-(gcd_u(a,modulus)==1u?1.0:0.0))<1e-12);
            }
            /* Enumeration must be injective: distinct indices, distinct tables. */
            for (unsigned prev=0u;prev<id;++prev) {
                const struct dirichlet_character *other=&catalogue[prev];
                unsigned distinguish=0u;
                for (unsigned n=0u;n<modulus;++n)
                    distinguish+=(c.phase[n]!=other->phase[n]);
                assert(distinguish>0u);
            }
        }
    }

    struct dirichlet_character chi4=generated(4,1);
    struct dirichlet_character chi3=generated(3,1);
    struct dirichlet_character chi5_plus=generated(5,1);
    struct dirichlet_character chi5_minus=generated(5,3);
    struct dirichlet_character chi8=generated(8,2);
    struct dirichlet_character induced=generated(8,1);
    struct dirichlet_character chi9_induced=generated(9,3);
    struct dirichlet_character zeta=generated(1,0);
    assert(chi4.conductor==4 && chi4.parity==1);
    assert(chi3.conductor==3 && chi3.parity==1);
    assert(chi5_plus.conductor==5 && chi5_plus.parity==1);
    assert(chi5_minus.conductor==5 && chi5_minus.parity==1);
    assert(chi8.conductor==8 && chi8.parity==0);
    assert(induced.conductor==4 && induced.parity==1);
    assert(chi9_induced.conductor==3);
    assert(zeta.conductor==1 && zeta.value_order==1);
    assert(near(dirichlet_characters_value(&chi5_plus,2),I,1e-13));
    assert(near(dirichlet_characters_value(&chi5_minus,2),-I,1e-13));
    assert(near(dirichlet_characters_value(&chi8,7),1.0,1e-13));
    assert(near(dirichlet_characters_value(&chi4,3),-1.0,1e-13));
    for (unsigned n=0u;n<=127u;++n) {
        assert(near(dirichlet_characters_value(&chi4,n),
                    (double)dirichlet_chi4(n),1e-13));
    }
    assert(near(dirichlet_characters_local_factor(&chi5_plus,2,2),
                (16.0+4.0*I)/17.0,1e-13));
    assert(near(dirichlet_characters_partial_sum(&zeta,3,2),
                1.0+1.0/4.0+1.0/9.0,1e-13));
    assert(near(dirichlet_characters_finite_product(&chi4,5,2),
                dirichlet_chi4_finite_euler_product(5,2),1e-13));

    /* Finite group orthogonality. Independent complex numeric check, NOT
       a proof by floating point, for several noncyclic and CRT groups. */
    const unsigned selected[]={3u,4u,5u,8u,9u,12u,15u,16u,24u,32u,105u,128u};
    for (unsigned s=0u;s<sizeof selected/sizeof selected[0];++s) {
        unsigned q=selected[s], count=dirichlet_characters_count(q);
        for (unsigned i=0u;i<count;++i) {
            struct dirichlet_character a=generated(q,i);
            double complex mean=0.0;
            for (unsigned n=0u;n<q;++n) mean+=dirichlet_characters_value(&a,n);
            assert(near(mean,i==0u?(double)count:0.0,1e-9));
            for (unsigned j=0u;j<count;++j) {
                struct dirichlet_character b=generated(q,j);
                double complex inner=0.0;
                for (unsigned n=0u;n<q;++n)
                    inner+=dirichlet_characters_value(&a,n)*
                           conj(dirichlet_characters_value(&b,n));
                assert(near(inner,i==j?(double)count:0.0,1e-9));
            }
        }
    }
    struct dirichlet_character corrupt=chi5_plus;
    corrupt.phase[1]=1;
    assert(!dirichlet_characters_verify(&corrupt));
    assert(!isfinite(creal(dirichlet_characters_value(&corrupt,2))));
    assert(!isfinite(creal(dirichlet_characters_partial_sum(&chi5_plus,128,2))));
    assert(!isfinite(creal(dirichlet_characters_local_factor(&chi5_plus,9,2))));
    assert(!isfinite(creal(dirichlet_characters_finite_product(&chi5_plus,32,2))));
    puts("Generated Dirichlet characters: exhaustive bounded CRT/axiom/orthogonality C11 fixtures passed");
    return 0;
}
