#include "dirichlet_view.h"

#include <math.h>
#include <stddef.h>

#define MIN_HALF_HEIGHT 0.025f
#define MAX_HALF_HEIGHT 80.0f

static bool dimensions(float width, float height) {
    return isfinite(width) && isfinite(height) && width > 0 && height > 0;
}

static void reset_camera(struct dirichlet_view *view) {
    if (view->model == DIRICHLET_GEOMETRIC) {
        view->center_x = 0;
        view->center_y = 0;
        view->half_height = 1.6f;
    } else {
        view->center_x = 1.1f;
        view->center_y = 0;
        view->half_height = 2.7f;
    }
}

void dirichlet_view_initialize(struct dirichlet_view *view) {
    if (view == NULL) return;
    view->model = DIRICHLET_GEOMETRIC;
    view->cutoff = 4u;
    view->prime = 3u;
    reset_camera(view);
}

bool dirichlet_view_select(struct dirichlet_view *view, enum dirichlet_view_model model) {
    if (view == NULL || model < DIRICHLET_GEOMETRIC ||
        model > DIRICHLET_EULER_PRODUCT) return false;
    if (view->model == model) return true;
    bool changes_plane = (view->model == DIRICHLET_GEOMETRIC)
        != (model == DIRICHLET_GEOMETRIC);
    view->model = model;
    if (model == DIRICHLET_GEOMETRIC) view->cutoff = 4u;
    else if (model == DIRICHLET_PARTIAL_SUM) view->cutoff = 31u;
    else if (model == DIRICHLET_EULER_PRODUCT) view->cutoff = 13u;
    else view->cutoff = 0u; /* unused in the local-factor shader */
    if (changes_plane) reset_camera(view);
    return true;
}

bool dirichlet_view_set_cutoff(struct dirichlet_view *view, unsigned cutoff) {
    if (view == NULL || view->model == DIRICHLET_LOCAL_FACTOR) return false;
    unsigned maximum = view->model == DIRICHLET_GEOMETRIC ? 32u
        : view->model == DIRICHLET_PARTIAL_SUM ? 127u : 31u;
    if (cutoff > maximum) return false;
    view->cutoff = cutoff; /* 0: empty sum/product, mathematically valid */
    return true;
}

static bool prime_allowed(unsigned prime) {
    if (prime < 2u || prime > 31u) return false;
    for (unsigned divisor = 2u; divisor <= prime / divisor; ++divisor) {
        if (prime % divisor == 0u) return false;
    }
    return true;
}

bool dirichlet_view_set_prime(struct dirichlet_view *view, unsigned prime) {
    if (view == NULL || !prime_allowed(prime)) return false;
    view->prime = prime;
    return true;
}

bool dirichlet_view_pan_pixels(
    struct dirichlet_view *view,
    float delta_x, float delta_y, float screen_height
) {
    if (view == NULL || !dimensions(1.0f, screen_height) ||
        !isfinite(delta_x) || !isfinite(delta_y)) return false;
    float ratio = 2.0f * view->half_height / screen_height;
    float next_x = view->center_x - ratio * delta_x;
    float next_y = view->center_y + ratio * delta_y;
    if (!isfinite(next_x) || !isfinite(next_y)) return false;
    view->center_x = next_x;
    view->center_y = next_y;
    return true;
}

bool dirichlet_view_world_point(
    const struct dirichlet_view *view,
    float x, float y, float width, float height, float out[2]
) {
    if (view == NULL || out == NULL || !dimensions(width, height) ||
        !isfinite(x) || !isfinite(y)) return false;
    float nx = 2.0f * x / width - 1.0f;
    float ny = 1.0f - 2.0f * y / height;
    float world_x = view->center_x + nx * view->half_height * (width/height);
    float world_y = view->center_y + ny * view->half_height;
    if (!isfinite(world_x) || !isfinite(world_y)) return false;
    out[0] = world_x;
    out[1] = world_y;
    return true;
}

bool dirichlet_view_zoom_at(
    struct dirichlet_view *view,
    float x, float y, float width, float height, float factor
) {
    if (view == NULL || !isfinite(factor) || factor <= 0.0f) return false;
    float anchor_before[2], anchor_after[2];
    if (!dirichlet_view_world_point(view,x,y,width,height,anchor_before))
        return false;
    struct dirichlet_view candidate = *view;
    candidate.half_height = fminf(MAX_HALF_HEIGHT,
        fmaxf(MIN_HALF_HEIGHT,view->half_height*factor));
    if (!dirichlet_view_world_point(
            &candidate,x,y,width,height,anchor_after)) return false;
    candidate.center_x += anchor_before[0]-anchor_after[0];
    candidate.center_y += anchor_before[1]-anchor_after[1];
    if (!isfinite(candidate.center_x) || !isfinite(candidate.center_y))
        return false;
    *view = candidate;
    return true;
}

bool dirichlet_view_uniforms(
    const struct dirichlet_view *view,
    float width, float height,
    struct dirichlet_glsl_uniforms *out
) {
    if (view == NULL || out == NULL || !dimensions(width,height)) return false;
    float aspect = width / height;
    if (!isfinite(aspect)) return false;
    out->center[0] = view->center_x;
    out->center[1] = view->center_y;
    out->half_height = view->half_height;
    out->aspect = aspect;
    out->model = (int)view->model;
    out->cutoff = (int)view->cutoff;
    out->prime = (int)view->prime;
    return true;
}
