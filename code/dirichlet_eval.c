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

/* Use scalar libm at the foreign ABI boundary; construct the mathematical
   complex value with the actual compiler's representation inside this unit. */
static double complex n_to_minus_s(unsigned n, double complex s) {
    double logarithm = log((double)n);
    double magnitude = exp(-creal(s) * logarithm);
    double angle = -cimag(s) * logarithm;
    return CMPLX(magnitude * cos(angle), magnitude * sin(angle));
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
    const struct character_definition *entry = &characters[character];
    if (entry->real[1u % modulus] != 1 || entry->imag[1u % modulus] != 0)
        return 0;
    for (unsigned a = 0u; a < modulus; ++a) {
        int real = entry->real[a], imag = entry->imag[a];
        int is_unit = gcd_unsigned(a, modulus) == 1u;
        if (real < -1 || real > 1 || imag < -1 || imag > 1) return 0;
        int norm_squared = real*real + imag*imag;
        if (norm_squared != (is_unit ? 1 : 0)) return 0;
        for (unsigned b = 0u; b < modulus; ++b) {
            /* The catalogue's Gaussian-integer laws are exact integer laws,
               not equality of rounded floating complex products. */
            int other_real = entry->real[b], other_imag = entry->imag[b];
            unsigned product_residue = (a*b) % modulus;
            if (entry->real[product_residue] != real*other_real - imag*other_imag ||
                entry->imag[product_residue] != real*other_imag + imag*other_real)
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
            total += coefficient * n_to_minus_s(n, s);
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
    return 1.0 / (1.0 - coefficient * n_to_minus_s(prime, s));
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
