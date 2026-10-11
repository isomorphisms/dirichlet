#include <assert.h>
#include <complex.h>
#include <dlfcn.h>
#include <math.h>
#include <stdio.h>
#include <string.h>

#include "../code/characters.h"

/* Linux x86_64 shared-object acceptance, not Android ABI acceptance.
   POSIX dlsym returns void*; memcpy avoids a non-ISO function-pointer cast.
   Function/data pointer sizes are checked for this particular host. */
typedef unsigned (*count_function)(unsigned);
typedef int (*generate_function)(unsigned,unsigned,struct dirichlet_character *);
typedef int (*verify_function)(const struct dirichlet_character *);
typedef double complex (*value_function)(const struct dirichlet_character *,unsigned);

int main(int argc, char **argv) {
    assert(argc==2);
    void *handle=dlopen(argv[1],RTLD_NOW|RTLD_LOCAL);
    if (handle==NULL) {
        fprintf(stderr,"dlopen: %s\n",dlerror());
        return 1;
    }
    count_function count=NULL;
    generate_function generate=NULL;
    verify_function verify=NULL;
    value_function value=NULL;
    _Static_assert(sizeof count==sizeof(void *),"dlsym pointer representation");
    _Static_assert(sizeof generate==sizeof(void *),"dlsym pointer representation");
    _Static_assert(sizeof verify==sizeof(void *),"dlsym pointer representation");
    _Static_assert(sizeof value==sizeof(void *),"dlsym pointer representation");
    void *symbol=dlsym(handle,"dirichlet_characters_count");
    assert(symbol!=NULL); memcpy(&count,&symbol,sizeof count);
    symbol=dlsym(handle,"dirichlet_characters_generate");
    assert(symbol!=NULL); memcpy(&generate,&symbol,sizeof generate);
    symbol=dlsym(handle,"dirichlet_characters_verify");
    assert(symbol!=NULL); memcpy(&verify,&symbol,sizeof verify);
    symbol=dlsym(handle,"dirichlet_characters_value");
    assert(symbol!=NULL); memcpy(&value,&symbol,sizeof value);
    assert(count(5)==4u && count(8)==4u && count(128)==64u);
    struct dirichlet_character chi;
    assert(generate(5,1,&chi));
    assert(verify(&chi));
    assert(chi.conductor==5u && chi.value_order==4u && chi.parity==1u);
    assert(cabs(value(&chi,2u)-I)<1e-13);
    assert(generate(8,2,&chi));
    assert(chi.conductor==8u && chi.parity==0u);
    assert(cabs(value(&chi,7u)-1.0)<1e-13);
    assert(generate(1,0,&chi));
    assert(cabs(value(&chi,0u)-1.0)<1e-13);
    assert(dlclose(handle)==0);
    puts("Standalone C11 shared-library dlopen C ABI checks passed");
    return 0;
}
