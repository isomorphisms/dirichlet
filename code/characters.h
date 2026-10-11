#ifndef DIRICHLET_CHARACTERS_H
#define DIRICHLET_CHARACTERS_H

#include <complex.h>
#include <stdint.h>

/*
 * A bounded, standalone C11 FFI for Dirichlet characters.
 *
 * Mathematics: every character of (Z/qZ)^x is enumerated for 1 <= q <= 128.
 * The bound is an implementation/resource limit, NOT a theorem restriction.
 * The exact coefficients are roots of unity: chi(n) = exp(2*pi*i*k/d).
 * Each non-unit has phase -1 (chi(n)=0). No complex floating point is
 * involved in generation, conductor, parity or character identities.
 *
 * ABI has no ownership or allocation: the caller owns the output struct.
 * Future larger moduli should version/extend the ABI, never silently
 * change sizeof(struct dirichlet_character).
 */
#define DIRICHLET_CHARACTER_MAX_MODULUS 128u

struct dirichlet_character {
    unsigned modulus;
    unsigned index;             /* 0 <= index < phi(modulus) */
    unsigned phase_denominator; /* exponent of the unit group */
    unsigned value_order;       /* multiplicative order of this character */
    unsigned conductor;         /* smallest inducing modulus dividing q */
    unsigned parity;            /* 0: even; 1: odd, chi(-1)=-1 */
    int16_t phase[DIRICHLET_CHARACTER_MAX_MODULUS];
};

/* Zero count or zero return means invalid/out-of-range input. */
unsigned dirichlet_characters_count(unsigned modulus);
int dirichlet_characters_generate(
    unsigned modulus, unsigned index, struct dirichlet_character *output);
/* Independently checks support, normalization, multiplication and metadata. */
int dirichlet_characters_verify(const struct dirichlet_character *character);

/* Bad descriptors and cutoffs return NaN + i*NaN. */
double complex dirichlet_characters_value(
    const struct dirichlet_character *character, unsigned n);
double complex dirichlet_characters_partial_sum(
    const struct dirichlet_character *character, unsigned last_n, double complex s);
double complex dirichlet_characters_local_factor(
    const struct dirichlet_character *character, unsigned prime, double complex s);
double complex dirichlet_characters_finite_product(
    const struct dirichlet_character *character, unsigned last_prime, double complex s);

#endif
