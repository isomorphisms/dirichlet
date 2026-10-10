#ifndef DIRICHLET_VIEW_H
#define DIRICHLET_VIEW_H

#include <stdbool.h>

/* Android GLES3 / WebGL2 uniform ABI. This struct is source-only and
   contains no Android or OpenGL dependencies. All four function modes
   evaluate the same complex coordinate in the GLSL fragment template. */
enum dirichlet_view_model {
    DIRICHLET_GEOMETRIC = 0,
    DIRICHLET_LOCAL_FACTOR = 1,
    DIRICHLET_PARTIAL_SUM = 2,
    DIRICHLET_EULER_PRODUCT = 3
};

struct dirichlet_view {
    enum dirichlet_view_model model;
    unsigned cutoff;
    unsigned prime;
    unsigned character;
    float center_x;
    float center_y;
    float half_height;
};

struct dirichlet_glsl_uniforms {
    float center[2]; /* u_center */
    float half_height; /* u_half_height */
    float aspect; /* u_aspect */
    int model; /* u_model */
    int cutoff; /* u_cutoff */
    int prime; /* u_prime */
    int character; /* u_character */
};

void dirichlet_view_initialize(struct dirichlet_view *view);
bool dirichlet_view_select(struct dirichlet_view *view, enum dirichlet_view_model model);
bool dirichlet_view_set_cutoff(struct dirichlet_view *view, unsigned cutoff);
bool dirichlet_view_set_prime(struct dirichlet_view *view, unsigned prime);
bool dirichlet_view_set_character(struct dirichlet_view *view, unsigned character);
bool dirichlet_view_pan_pixels(
    struct dirichlet_view *view,
    float delta_x, float delta_y, float screen_height
);
bool dirichlet_view_world_point(
    const struct dirichlet_view *view,
    float x, float y, float width, float height, float out[2]
);
bool dirichlet_view_zoom_at(
    struct dirichlet_view *view,
    float x, float y, float width, float height, float factor
);
bool dirichlet_view_uniforms(
    const struct dirichlet_view *view,
    float width, float height,
    struct dirichlet_glsl_uniforms *output
);

#endif
