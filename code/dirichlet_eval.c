#include "dirichlet_eval.h"

#include <math.h>

/* Exact Gaussian-integer residue tables, indexed by n modulo the modulus.
   Each entry has real and imaginary components in { -1, 0, +1 }. */
struct character_definition {
    unsigned modulus;
    signed char real[8];
    signed char imag[8];
};
static const struct character_definition characters[DIRICHLET_CHARACTER_COUNT] = {
    {4u, {0, 1, 0, -1}, {0}},
    {3u, {0, 1, -1}, {0}},
    {5u, {0, 1, 0, 0, -1}, {0, 0, 1, -1}},
    {5u, {0, 1, 0, 0, -1}, {0, 0, -1, 1}},
    {8u, {0, 1, 0, -1, 0, -1, 0, 1}, {0}},
    {4u, {0, 1, 0, 1}, {0}},
    {1u, {1}, {0}}
};

static double complex invalid_value(void) {
    return CMPLX(NAN, NAN);
}

unsigned dirichlet_character_modulus(unsigned character) {
    return character < DIRICHLET_CHARACTER_COUNT
        ? characters[character].modulus : 0u;
}

double complex dirichlet_character_value(unsigned character, unsigned n) {
    if (character >= DIRICHLET_CHARACTER_COUNT) return invalid_value();
    const struct character_definition *entry = &characters[character];
    unsigned residue = n % entry->modulus;
    return CMPLX(entry->real[residue], entry->imag[residue]);
}

static unsigned gcd_unsigned(unsigned a, unsigned b) {
    while (b != 0u) {
        unsigned remainder = a % b;
        a = b;
        b = remainder;
    }
    return a;
}

int dirichlet_character_table_valid(unsigned character) {
    unsigned modulus = dirichlet_character_modulus(character);
    if (modulus == 0u) return 0;
    if (dirichlet_character_value(character, 1u) != 1.0) return 0;
    for (unsigned a = 0u; a < modulus; ++a) {
        double complex value = dirichlet_character_value(character, a);
        int is_unit = gcd_unsigned(a, modulus) == 1u;
        double norm_squared = creal(value)*creal(value) + cimag(value)*cimag(value);
        if (norm_squared != (is_unit ? 1.0 : 0.0)) return 0;
        for (unsigned b = 0u; b < modulus; ++b) {
            double complex product = value * dirichlet_character_value(character,b);
            if (dirichlet_character_value(character,(a*b)%modulus) != product)
                return 0;
        }
    }
    return 1;
}

int dirichlet_chi4(unsigned n) {
    return (int)creal(dirichlet_character_value(DIRICHLET_CHI4,n));
}

int dirichlet_is_prime(unsigned n) {
    if (n < 2u) return 0;
    for (unsigned divisor = 2u; divisor <= n / divisor; ++divisor)
        if (n % divisor == 0u) return 0;
    return 1;
}

double complex dirichlet_geometric(unsigned terms, double complex q) {
    if (terms > DIRICHLET_MAX_GEOMETRIC) return invalid_value();
    double complex total = 0.0;
    double complex power = 1.0;
    for (unsigned k = 0u; k < terms; ++k) {
        total += power;
        power *= q;
    }
    return total; /* Regular at q=1. */
}

double complex dirichlet_character_partial_sum(
    unsigned character, unsigned last_n, double complex s
) {
    if (character >= DIRICHLET_CHARACTER_COUNT || last_n > DIRICHLET_MAX_SERIES)
        return invalid_value();
    double complex total = 0.0;
    for (unsigned n = 1u; n <= last_n; ++n) {
        double complex coefficient = dirichlet_character_value(character,n);
        if (coefficient != 0.0)
            total += coefficient * cexp(-s * log((double)n));
    }
    return total;
}

double complex dirichlet_character_local_factor(
    unsigned character, unsigned prime, double complex s
) {
    if (character >= DIRICHLET_CHARACTER_COUNT ||
        prime > DIRICHLET_MAX_PRIME || !dirichlet_is_prime(prime))
        return invalid_value();
    double complex coefficient = dirichlet_character_value(character,prime);
    return 1.0 / (1.0 - coefficient * cexp(-s * log((double)prime)));
}

double complex dirichlet_character_finite_euler_product(
    unsigned character, unsigned last_prime, double complex s
) {
    if (character >= DIRICHLET_CHARACTER_COUNT || last_prime > DIRICHLET_MAX_PRIME)
        return invalid_value();
    double complex total = 1.0;
    for (unsigned p = 2u; p <= last_prime; ++p)
        if (dirichlet_is_prime(p))
            total *= dirichlet_character_local_factor(character,p,s);
    return total;
}

/* Preserve the original API without carrying a second evaluation engine. */
double complex dirichlet_chi4_partial_sum(unsigned last_n, double complex s) {
    return dirichlet_character_partial_sum(DIRICHLET_CHI4,last_n,s);
}
double complex dirichlet_chi4_local_factor(unsigned prime, double complex s) {
    return dirichlet_character_local_factor(DIRICHLET_CHI4,prime,s);
}
double complex dirichlet_chi4_finite_euler_product(unsigned last_prime, double complex s) {
    return dirichlet_character_finite_euler_product(DIRICHLET_CHI4,last_prime,s);
}
