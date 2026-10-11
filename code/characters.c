#include "characters.h"

#include <math.h>
#include <stddef.h>
#include <string.h>

enum { MAX_FACTORS = 8, MAX_COORDINATES = 16,
       MAX_SERIES = 127, MAX_PRIME = 31 };

struct local_factor {
    unsigned modulus;
    unsigned count;
    unsigned generators[2];
    unsigned orders[2];
    unsigned first_coordinate;
};
struct unit_basis {
    struct local_factor factors[MAX_FACTORS];
    unsigned factor_count;
    unsigned coordinate_count;
    unsigned orders[MAX_COORDINATES];
    unsigned character_count;
    unsigned phase_denominator;
};

static unsigned gcd_u(unsigned a, unsigned b) {
    while (b != 0u) {
        unsigned r = a % b;
        a = b;
        b = r;
    }
    return a;
}
static unsigned pow_mod(unsigned base, unsigned exp, unsigned modulus) {
    unsigned value = 1u % modulus;
    while (exp != 0u) {
        if (exp & 1u) value = (value * base) % modulus;
        base = (base * base) % modulus;
        exp >>= 1u;
    }
    return value;
}
static unsigned totient(unsigned modulus) {
    if (modulus == 0u) return 0u;
    unsigned answer = modulus, remaining = modulus;
    for (unsigned p=2u; p <= remaining / p; ++p) {
        if (remaining % p != 0u) continue;
        answer -= answer / p;
        do { remaining /= p; } while (remaining % p == 0u);
    }
    if (remaining > 1u) answer -= answer / remaining;
    return answer;
}
unsigned dirichlet_characters_count(unsigned modulus) {
    return modulus >= 1u && modulus <= DIRICHLET_CHARACTER_MAX_MODULUS
        ? totient(modulus) : 0u;
}
static int primitive_root(unsigned candidate, unsigned modulus, unsigned order) {
    if (gcd_u(candidate, modulus) != 1u) return 0;
    unsigned remaining = order;
    for (unsigned p=2u; p <= remaining / p; ++p) {
        if (remaining % p != 0u) continue;
        if (pow_mod(candidate,order/p,modulus) == 1u) return 0;
        do { remaining /= p; } while (remaining % p == 0u);
    }
    if (remaining > 1u && pow_mod(candidate,order/remaining,modulus)==1u)
        return 0;
    return 1;
}
static int append_factor(struct unit_basis *basis, unsigned prime, unsigned power) {
    if (basis->factor_count >= MAX_FACTORS) return 0;
    struct local_factor *f = &basis->factors[basis->factor_count++];
    f->modulus = power;
    f->count = 0u;
    f->first_coordinate = basis->coordinate_count;
    if (prime == 2u) {
        if (power == 4u) {
            f->count=1u; f->generators[0]=3u; f->orders[0]=2u;
        } else if (power >= 8u) {
            f->count=2u; f->generators[0]=power-1u; f->orders[0]=2u;
            f->generators[1]=5u; f->orders[1]=power/4u;
        }
        /* Modulo 2: the unit group is trivial. */
    } else {
        unsigned order=power-power/prime;
        unsigned generator;
        for (generator=2u; generator<power; ++generator)
            if (primitive_root(generator,power,order)) break;
        if (generator==power) return 0;
        f->count=1u; f->generators[0]=generator; f->orders[0]=order;
    }
    for (unsigned j=0u; j<f->count; ++j) {
        if (basis->coordinate_count >= MAX_COORDINATES) return 0;
        unsigned order=f->orders[j];
        basis->orders[basis->coordinate_count++]=order;
        basis->character_count *= order;
        unsigned d=gcd_u(basis->phase_denominator,order);
        basis->phase_denominator *= order/d;
    }
    return 1;
}
static int make_basis(unsigned modulus, struct unit_basis *basis) {
    if (dirichlet_characters_count(modulus)==0u) return 0;
    memset(basis,0,sizeof *basis);
    basis->character_count=1u;
    basis->phase_denominator=1u;
    unsigned remaining=modulus;
    for (unsigned p=2u; p <= remaining/p; ++p) {
        if (remaining%p!=0u) continue;
        unsigned power=1u;
        do { power*=p; remaining/=p; } while (remaining%p==0u);
        if (!append_factor(basis,p,power)) return 0;
    }
    if (remaining>1u && !append_factor(basis,remaining,remaining)) return 0;
    return basis->character_count==totient(modulus);
}

/* Discrete logarithms in the local cyclic factor(s); this also handles
   noncyclic 2-power groups C2 x C_(2^(a-2)), without a fake generator. */
static int local_logs(const struct local_factor *f, unsigned residue, unsigned logs[2]) {
    if (f->count==0u) return residue == 1u % f->modulus;
    unsigned amax=f->orders[0], bmax=f->count==2u?f->orders[1]:1u;
    for (unsigned a=0u; a<amax; ++a) {
        unsigned pa=pow_mod(f->generators[0],a,f->modulus);
        for (unsigned b=0u; b<bmax; ++b) {
            unsigned pb=f->count==2u?pow_mod(f->generators[1],b,f->modulus):1u;
            if ((pa*pb)%f->modulus==residue) {
                logs[0]=a;
                logs[1]=b;
                return 1;
            }
        }
    }
    return 0;
}
static unsigned derived_conductor(const struct dirichlet_character *c) {
    unsigned q=c->modulus;
    for (unsigned d=1u; d<=q; ++d) {
        if (q%d!=0u) continue;
        int factors_through=1;
        unsigned identity=1u%d;
        for (unsigned n=0u; n<q; ++n) {
            if (gcd_u(n,q)==1u && n%d==identity && c->phase[n]!=0) {
                factors_through=0;
                break;
            }
        }
        if (factors_through) return d;
    }
    return 0u;
}
static unsigned derived_value_order(const struct dirichlet_character *c) {
    unsigned divisor=c->phase_denominator;
    for (unsigned n=0u; n<c->modulus; ++n)
        if (c->phase[n]>=0) divisor=gcd_u(divisor,(unsigned)c->phase[n]);
    return c->phase_denominator/divisor;
}
int dirichlet_characters_generate(
    unsigned modulus, unsigned index, struct dirichlet_character *output
) {
    struct unit_basis basis;
    if (output==NULL || !make_basis(modulus,&basis) ||
        index>=basis.character_count) return 0;
    struct dirichlet_character candidate;
    memset(&candidate,0,sizeof candidate);
    candidate.modulus=modulus;
    candidate.index=index;
    candidate.phase_denominator=basis.phase_denominator;
    for (unsigned n=0u; n<DIRICHLET_CHARACTER_MAX_MODULUS; ++n)
        candidate.phase[n]=-1;
    unsigned coordinates[MAX_COORDINATES]={0};
    unsigned remaining=index;
    for (unsigned j=0u; j<basis.coordinate_count; ++j) {
        coordinates[j]=remaining%basis.orders[j];
        remaining/=basis.orders[j];
    }
    for (unsigned n=0u; n<modulus; ++n) {
        if (gcd_u(n,modulus)!=1u) continue;
        unsigned exponent=0u;
        for (unsigned i=0u; i<basis.factor_count; ++i) {
            const struct local_factor *f=&basis.factors[i];
            unsigned logs[2]={0u,0u};
            if (!local_logs(f,n%f->modulus,logs)) return 0;
            for (unsigned j=0u; j<f->count; ++j) {
                unsigned coordinate=f->first_coordinate+j;
                unsigned contribution=coordinates[coordinate]*logs[j]*
                    (basis.phase_denominator/f->orders[j]);
                exponent=(exponent+contribution)%basis.phase_denominator;
            }
        }
        candidate.phase[n]=(int16_t)exponent;
    }
    candidate.value_order=derived_value_order(&candidate);
    candidate.conductor=derived_conductor(&candidate);
    unsigned at_minus_one=(modulus-1u)%modulus;
    unsigned minus_phase=(unsigned)candidate.phase[at_minus_one];
    if (minus_phase==0u) candidate.parity=0u;
    else if (2u*minus_phase==candidate.phase_denominator) candidate.parity=1u;
    else return 0; /* Failure of a required character identity. */
    if (candidate.conductor==0u) return 0;
    *output=candidate;
    return 1;
}
int dirichlet_characters_verify(const struct dirichlet_character *c) {
    if (c==NULL || dirichlet_characters_count(c->modulus)==0u ||
        c->index>=dirichlet_characters_count(c->modulus) ||
        c->phase_denominator==0u || c->phase_denominator>DIRICHLET_CHARACTER_MAX_MODULUS ||
        c->phase[1u%c->modulus]!=0 || c->parity>1u) return 0;
    unsigned q=c->modulus;
    for (unsigned a=0u; a<DIRICHLET_CHARACTER_MAX_MODULUS; ++a) {
        int expected_unit=(a<q && gcd_u(a,q)==1u);
        int phase=c->phase[a];
        if (!expected_unit) { if (phase!=-1) return 0; continue; }
        if (phase<0 || (unsigned)phase>=c->phase_denominator) return 0;
        for (unsigned b=0u; b<q; ++b) {
            unsigned residue=(a*b)%q;
            if (c->phase[b]<0) {
                if (c->phase[residue]!=-1) return 0;
            } else if (c->phase[residue] !=
                (phase+c->phase[b])%(int)c->phase_denominator) return 0;
        }
    }
    if (derived_value_order(c)!=c->value_order ||
        derived_conductor(c)!=c->conductor) return 0;
    int16_t at_minus_one=c->phase[(q-1u)%q];
    if ((c->parity==0u && at_minus_one!=0) ||
        (c->parity==1u && (unsigned)(2*at_minus_one)!=c->phase_denominator))
        return 0;
    return 1;
}
static double complex invalid_value(void) { return CMPLX(NAN,NAN); }
static double complex coefficient(const struct dirichlet_character *c, unsigned n) {
    int exponent=c->phase[n%c->modulus];
    if (exponent<0) return 0.0;
    double angle=(2.0*acos(-1.0)*(double)exponent)/(double)c->phase_denominator;
    return CMPLX(cos(angle),sin(angle));
}
double complex dirichlet_characters_value(
    const struct dirichlet_character *c, unsigned n
) {
    if (!dirichlet_characters_verify(c)) return invalid_value();
    return coefficient(c,n);
}
static int is_prime(unsigned n) {
    if (n<2u) return 0;
    for (unsigned d=2u; d<=n/d; ++d) if (n%d==0u) return 0;
    return 1;
}
double complex dirichlet_characters_partial_sum(
    const struct dirichlet_character *c, unsigned last_n, double complex s
) {
    if (last_n>MAX_SERIES || !dirichlet_characters_verify(c))
        return invalid_value();
    double complex total=0.0;
    for (unsigned n=1u; n<=last_n; ++n) {
        if (c->phase[n%c->modulus]<0) continue;
        total+=coefficient(c,n)*cexp(-s*log((double)n));
    }
    return total;
}
double complex dirichlet_characters_local_factor(
    const struct dirichlet_character *c, unsigned prime, double complex s
) {
    if (prime>MAX_PRIME || !is_prime(prime) || !dirichlet_characters_verify(c))
        return invalid_value();
    return 1.0/(1.0-coefficient(c,prime)*cexp(-s*log((double)prime)));
}
double complex dirichlet_characters_finite_product(
    const struct dirichlet_character *c, unsigned last_prime, double complex s
) {
    if (last_prime>MAX_PRIME || !dirichlet_characters_verify(c))
        return invalid_value();
    double complex total=1.0;
    for (unsigned p=2u;p<=last_prime;++p) {
        if (!is_prime(p)) continue;
        total*=1.0/(1.0-coefficient(c,p)*cexp(-s*log((double)p)));
    }
    return total;
}
