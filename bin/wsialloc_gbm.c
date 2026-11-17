#define _GNU_SOURCE

#include "wsialloc.h"
#include <gbm.h>

#include <dlfcn.h>
#include <fcntl.h>
#include <limits.h>
#include <pthread.h>
#include <stdint.h>
#include <stdlib.h>
#include <string.h>
#include <sys/mman.h>
#include <unistd.h>

_Static_assert(WSIALLOC_INTERFACE_VERSION == 3, "wsialloc v3 required");

struct gbm_api {
    struct gbm_device *(*new_device)(int);
    void (*del_device)(struct gbm_device *);
    const char *(*backend)(struct gbm_device *);
    int (*format_ok)(struct gbm_device *, uint32_t, uint32_t);
    struct gbm_bo *(*new_bo)(struct gbm_device *, uint32_t, uint32_t, uint32_t, uint32_t);
    void (*del_bo)(struct gbm_bo *);
    int (*planes)(struct gbm_bo *);
    uint32_t (*format)(struct gbm_bo *);
    uint64_t (*modifier)(struct gbm_bo *);
    uint32_t (*stride)(struct gbm_bo *, size_t);
    uint32_t (*offset)(struct gbm_bo *, size_t);
    uint32_t (*plane_size)(struct gbm_bo *, size_t);
    int (*plane_fd)(struct gbm_bo *, size_t);
    void *(*map)(struct gbm_bo *, uint32_t, uint32_t, uint32_t, uint32_t, uint32_t, uint32_t *, void **);
    void (*unmap)(struct gbm_bo *, void *);
};

struct wsialloc_allocator {
    int fd;
    struct gbm_device *dev;
    pthread_mutex_t lock;
};

static pthread_mutex_t lock = PTHREAD_MUTEX_INITIALIZER;
static void *handle;
static struct gbm_api g;
#define EXPORT __attribute__((visibility("default")))

static int load_sym(void *h, const char *name, void *dst, size_t size)
{
    void *p = dlsym(h, name);
    if (p == NULL || size != sizeof p) return -1;
    memcpy(dst, &p, size);
    return 0;
}

static int load_gbm(void)
{
    if (pthread_mutex_lock(&lock) != 0) return -1;
    if (handle != NULL) {
        (void)pthread_mutex_unlock(&lock);
        return 0;
    }

    void *h = dlopen("/opt/libmali/libminigbm-wsi.so.1.0.0", RTLD_NOW | RTLD_LOCAL | RTLD_DEEPBIND);
    if (h == NULL) {
        (void)pthread_mutex_unlock(&lock);
        return -1;
    }

    struct gbm_api api = {0};
    if (load_sym(h, "gbm_create_device", &api.new_device, sizeof api.new_device) ||
        load_sym(h, "gbm_device_destroy", &api.del_device, sizeof api.del_device) ||
        load_sym(h, "gbm_device_get_backend_name", &api.backend, sizeof api.backend) ||
        load_sym(h, "gbm_device_is_format_supported", &api.format_ok, sizeof api.format_ok) ||
        load_sym(h, "gbm_bo_create", &api.new_bo, sizeof api.new_bo) ||
        load_sym(h, "gbm_bo_destroy", &api.del_bo, sizeof api.del_bo) ||
        load_sym(h, "gbm_bo_get_plane_count", &api.planes, sizeof api.planes) ||
        load_sym(h, "gbm_bo_get_format", &api.format, sizeof api.format) ||
        load_sym(h, "gbm_bo_get_modifier", &api.modifier, sizeof api.modifier) ||
        load_sym(h, "gbm_bo_get_stride_for_plane", &api.stride, sizeof api.stride) ||
        load_sym(h, "gbm_bo_get_offset", &api.offset, sizeof api.offset) ||
        load_sym(h, "gbm_bo_get_plane_size", &api.plane_size, sizeof api.plane_size) ||
        load_sym(h, "gbm_bo_get_plane_fd", &api.plane_fd, sizeof api.plane_fd) ||
        load_sym(h, "gbm_bo_map", &api.map, sizeof api.map) ||
        load_sym(h, "gbm_bo_unmap", &api.unmap, sizeof api.unmap)) {
        (void)dlclose(h);
        (void)pthread_mutex_unlock(&lock);
        return -1;
    }

    g = api;
    handle = h;
    (void)pthread_mutex_unlock(&lock);
    return 0;
}

static void init_result(wsialloc_allocate_result *r)
{
    memset(r, 0, sizeof *r);
    for (size_t i = 0; i < WSIALLOC_MAX_PLANES; ++i) r->buffer_fds[i] = -1;
}

static bool format_ok(uint32_t f)
{
    return f == DRM_FORMAT_ABGR8888 || f == DRM_FORMAT_ARGB8888;
}

static bool layout(struct gbm_bo *b, const wsialloc_allocate_info *in,
                   const wsialloc_format *f, uint32_t *stride, uint32_t *size)
{
    if (g.planes(b) != 1 || g.format(b) != f->fourcc || g.modifier(b) != DRM_FORMAT_MOD_LINEAR) return false;

    uint32_t s = g.stride(b, 0), off = g.offset(b, 0), n = g.plane_size(b, 0);
    uint64_t row = (uint64_t)in->width * 4u, need = (uint64_t)s * in->height;
    if (off != 0 || s > INT_MAX || (uint64_t)s < row || need > n) return false;
    *stride = s;
    *size = n;
    return true;
}

static int zero(struct gbm_bo *b, uint32_t w, uint32_t h, uint32_t size)
{
    uint32_t stride = 0;
    void *data = NULL;
    void *p = g.map(b, 0, 0, w, h, GBM_BO_TRANSFER_WRITE, &stride, &data);
    if (p == NULL || p == MAP_FAILED) return -1;

    if ((uint64_t)stride < (uint64_t)w * 4u || (uint64_t)stride * h > size) {
        g.unmap(b, data);
        return -1;
    }
    memset(p, 0, size);
    g.unmap(b, data);
    return 0;
}

EXPORT const uint32_t WSIALLOC_IMPLEMENTATION_VERSION_SYMBOL = WSIALLOC_INTERFACE_VERSION;

EXPORT wsialloc_error wsialloc_new(wsialloc_allocator **out)
{
    if (out == NULL) return WSIALLOC_ERROR_INVALID;
    *out = NULL;
    if (load_gbm() != 0) return WSIALLOC_ERROR_NO_RESOURCE;

    wsialloc_allocator *a = calloc(1, sizeof *a);
    if (a == NULL) return WSIALLOC_ERROR_NO_RESOURCE;
    a->fd = open("/dev/dri/renderD128", O_RDWR | O_CLOEXEC);
    if (a->fd < 0) goto fail;
    a->dev = g.new_device(a->fd);
    const char *backend = a->dev ? g.backend(a->dev) : NULL;
    if (backend == NULL || strcmp(backend, "mediatek") != 0) goto fail;
    if (pthread_mutex_init(&a->lock, NULL) != 0) goto fail;
    *out = a;
    return WSIALLOC_ERROR_NONE;

fail:
    if (a->dev != NULL) g.del_device(a->dev);
    if (a->fd >= 0) (void)close(a->fd);
    free(a);
    return WSIALLOC_ERROR_NO_RESOURCE;
}

EXPORT void wsialloc_delete(wsialloc_allocator *a)
{
    if (a == NULL) return;
    g.del_device(a->dev);
    (void)close(a->fd);
    (void)pthread_mutex_destroy(&a->lock);
    free(a);
}

EXPORT wsialloc_error wsialloc_alloc(wsialloc_allocator *a,
                                      const wsialloc_allocate_info *in,
                                      wsialloc_allocate_result *out)
{
    if (out == NULL) return WSIALLOC_ERROR_INVALID;
    init_result(out);
    if (a == NULL || in == NULL || in->formats == NULL) return WSIALLOC_ERROR_INVALID;
    if (in->format_count == 0 || in->width == 0 || in->height == 0) return WSIALLOC_ERROR_INVALID;

    uint64_t flags = WSIALLOC_ALLOCATE_NO_MEMORY | WSIALLOC_ALLOCATE_HIGHEST_FIXED_RATE_COMPRESSION;
    if (in->flags & ~flags) return WSIALLOC_ERROR_NOT_SUPPORTED;
    bool no_mem = (in->flags & WSIALLOC_ALLOCATE_NO_MEMORY) != 0;
    uint32_t usage = GBM_BO_USE_SCANOUT | GBM_BO_USE_RENDERING | GBM_BO_USE_LINEAR;
    wsialloc_error ret = WSIALLOC_ERROR_NOT_SUPPORTED;
    if (pthread_mutex_lock(&a->lock) != 0) return WSIALLOC_ERROR_NO_RESOURCE;

    for (unsigned i = 0; i < in->format_count; ++i) {
        const wsialloc_format *f = &in->formats[i];
        if (!format_ok(f->fourcc) || f->modifier != DRM_FORMAT_MOD_LINEAR ||
            (f->flags & ~(uint64_t)WSIALLOC_FORMAT_NON_DISJOINT) != 0 ||
            g.format_ok(a->dev, f->fourcc, usage) <= 0) continue;

        uint32_t stride = 0, size = 0;
        struct gbm_bo *b = NULL;
        if (no_mem) {
            uint64_t s = ((uint64_t)in->width * 4u + 63u) & ~UINT64_C(63);
            if (s > INT_MAX) continue;
            stride = (uint32_t)s;
        } else {
            b = g.new_bo(a->dev, in->width, in->height, f->fourcc, usage);
            if (b == NULL) {
                ret = WSIALLOC_ERROR_NO_RESOURCE;
                continue;
            }
            if (!layout(b, in, f, &stride, &size)) {
                g.del_bo(b);
                continue;
            }
        }

        int fd = -1;
        if (!no_mem) {
            if (zero(b, in->width, in->height, size) != 0 || (fd = g.plane_fd(b, 0)) < 0) {
                g.del_bo(b);
                ret = WSIALLOC_ERROR_NO_RESOURCE;
                continue;
            }
        }

        out->format = *f;
        out->average_row_strides[0] = (int)stride;
        out->offsets[0] = 0;
        out->buffer_fds[0] = fd;
        out->is_disjoint = false;
        if (b != NULL) g.del_bo(b);
        ret = WSIALLOC_ERROR_NONE;
        break;
    }

    (void)pthread_mutex_unlock(&a->lock);
    return ret;
}
