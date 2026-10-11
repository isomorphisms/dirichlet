#include <assert.h>
#include <math.h>
#include <stdio.h>

#include "../code/dirichlet_view.h"
#include "../code/dirichlet_eval.h"

static int near(float left, float right) {
    return fabsf(left-right) < 0.00015f;
}

int main(void) {
    struct dirichlet_view view;
    dirichlet_view_initialize(&view);
    assert(view.model == DIRICHLET_GEOMETRIC);
    assert(view.cutoff == 4 && view.prime == 3 && view.character == 0);
    assert(dirichlet_view_set_character(&view,DIRICHLET_CHI5_PLUS));
    assert(!dirichlet_view_set_character(&view,99));
    assert(view.character == DIRICHLET_CHI5_PLUS);
    assert(near(view.center_x,0) && near(view.center_y,0));
    assert(near(view.half_height,1.6f));
    assert(dirichlet_view_set_cutoff(&view,0));
    assert(dirichlet_view_set_cutoff(&view,32));
    assert(!dirichlet_view_set_cutoff(&view,33));
    assert(view.cutoff == 32);

    /* Switch q-plane to s-plane: reset; s-plane to s-plane: retain. */
    assert(dirichlet_view_select(&view, DIRICHLET_LOCAL_FACTOR));
    assert(near(view.center_x,1.1f) && near(view.half_height,2.7f));
    assert(!dirichlet_view_set_cutoff(&view,5));
    assert(!dirichlet_view_set_prime(&view,9));
    assert(!dirichlet_view_set_prime(&view,33));
    assert(dirichlet_view_set_prime(&view,2));
    assert(dirichlet_view_set_prime(&view,31));
    assert(view.prime == 31);
    assert(dirichlet_view_select(&view,DIRICHLET_PARTIAL_SUM));
    assert(view.cutoff == 31);
    assert(dirichlet_view_set_cutoff(&view,127));
    assert(!dirichlet_view_set_cutoff(&view,128));
    assert(dirichlet_view_pan_pixels(&view,10.0f,-20.0f,1000.0f));
    assert(near(view.center_x,1.046f));
    assert(near(view.center_y,-0.108f));

    float before[2], after[2];
    assert(dirichlet_view_world_point(&view,800,300,1000,800,before));
    assert(dirichlet_view_zoom_at(&view,800,300,1000,800,0.5f));
    assert(dirichlet_view_world_point(&view,800,300,1000,800,after));
    assert(near(before[0],after[0]) && near(before[1],after[1]));
    assert(near(view.half_height,1.35f));

    struct dirichlet_glsl_uniforms uniforms;
    assert(dirichlet_view_uniforms(&view,576,1152,&uniforms));
    assert(near(uniforms.aspect,0.5f));
    assert(uniforms.model == DIRICHLET_PARTIAL_SUM && uniforms.cutoff == 127);
    assert(uniforms.prime == 31);
    assert(uniforms.character == DIRICHLET_CHI5_PLUS);
    assert(uniforms.uses_generated == 0);
    assert(uniforms.generated_modulus == 1);
    assert(uniforms.generated_denominator == 1);
    assert(dirichlet_view_set_generated(&view,5,1));
    assert(!dirichlet_view_set_generated(&view,0,0));
    assert(!dirichlet_view_set_generated(&view,129,0));
    assert(!dirichlet_view_set_generated(&view,5,4));
    assert(view.uses_generated);
    assert(dirichlet_view_uniforms(&view,576,1152,&uniforms));
    assert(uniforms.uses_generated == 1);
    assert(uniforms.generated_modulus == 5);
    assert(uniforms.generated_denominator == 4);
    assert(uniforms.generated_phases[0] == -1);
    assert(uniforms.generated_phases[1] == 0);
    assert(uniforms.generated_phases[2] == 1);
    assert(uniforms.generated_phases[3] == 3);
    assert(uniforms.generated_phases[4] == 2);
    assert(uniforms.generated_phases[5] == -1);
    assert(dirichlet_view_set_character(&view,DIRICHLET_CHI8));
    assert(!view.uses_generated);
    assert(dirichlet_view_uniforms(&view,576,1152,&uniforms));
    assert(uniforms.uses_generated == 0);
    assert(dirichlet_view_set_generated(&view,128,15));
    assert(dirichlet_view_uniforms(&view,576,1152,&uniforms));
    assert(uniforms.generated_modulus == 128);
    assert(uniforms.generated_phases[127] >= 0);
    float remembered_x=view.center_x;
    float remembered_y=view.center_y;
    assert(dirichlet_view_select(&view,DIRICHLET_EULER_PRODUCT));
    assert(near(view.center_x,remembered_x));
    assert(near(view.center_y,remembered_y));
    assert(view.cutoff == 13);
    assert(dirichlet_view_set_cutoff(&view,0));
    assert(dirichlet_view_set_cutoff(&view,31));
    assert(!dirichlet_view_set_cutoff(&view,32));

    assert(dirichlet_view_select(&view,DIRICHLET_GEOMETRIC));
    assert(near(view.center_x,0) && near(view.half_height,1.6f));
    assert(view.cutoff == 4);
    assert(!dirichlet_view_zoom_at(&view,100,100,576,1152,-1.0f));
    assert(!dirichlet_view_pan_pixels(&view,0,NAN,1152));
    assert(!dirichlet_view_uniforms(&view,576,0,&uniforms));
    assert(!dirichlet_view_select(&view,(enum dirichlet_view_model)99));

    puts("Dirichlet portable viewport/uniform ABI fixtures passed");
    return 0;
}
