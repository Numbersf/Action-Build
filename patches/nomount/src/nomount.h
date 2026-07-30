#ifndef _LINUX_NOMOUNT_H
#define _LINUX_NOMOUNT_H

#include <linux/types.h>
#include <linux/list.h>
#include <linux/hashtable.h>
#include <linux/atomic.h>
#include <net/sock.h>
#include <net/genetlink.h>
#include <linux/version.h>
#if LINUX_VERSION_CODE >= KERNEL_VERSION(6, 12, 0)
#include <linux/unaligned.h>
#else
#include <asm/unaligned.h>
#endif
#include <linux/jump_label.h>

#define NOMOUNT_VERSION    10
#define NOMOUNT_HASH_BITS  12
#define NOMOUNT_UID_HASH_BITS 4
#define NM_FLAG_IS_DIR      (1 << 1)
#define NM_INO_TYPE_REAL    (1 << 0)
#define NM_INO_TYPE_VIRTUAL (1 << 1)
#define NM_INO_TYPE_DIR     (1 << 2)

static DEFINE_HASHTABLE(nomount_rules_ht,     NOMOUNT_HASH_BITS);
static DEFINE_HASHTABLE(nomount_inodes_ht,    NOMOUNT_HASH_BITS);
static DEFINE_HASHTABLE(nomount_basenames_ht, NOMOUNT_HASH_BITS);
static DEFINE_HASHTABLE(nomount_uid_ht,       NOMOUNT_UID_HASH_BITS);
static LIST_HEAD(nomount_rules_list);
static LIST_HEAD(nomount_private_dirs_list);
static DEFINE_MUTEX(nomount_write_mutex);

struct nm_inode_node {
    struct hlist_node node;
    unsigned long ino;
    dev_t dev;
    u8 type;
    u16 len;
};

struct nomount_child_name {
    unsigned long fake_ino;
    u16 name_len;
    u8 d_type;
    char name[256];
};

struct nm_child_array {
    atomic_t refcnt;
    u32 num_children;
    struct rcu_head rcu;
    struct nomount_child_name entries[]; /* Flexible array member */
};

struct nomount_dir_node {
    struct nm_inode_node dir;
    struct list_head private_list;
    struct nm_child_array __rcu *child_array; 
    char *dir_path;
    bool is_private;
};

struct nomount_rule {
    struct list_head list;
    struct nm_inode_node real_node; 
    struct nm_inode_node virt_node;
    struct hlist_node vpath_node;
    struct hlist_node basename_node;
    struct nomount_dir_node *parent_dir;
    char *virtual_path;
    char *real_path;
    const char *basename;
    u32 v_fs_type;
    u32 v_hash;
    u32 b_hash;
    u16 b_len;
    u8  flags;
};

struct nomount_uid_node {
    struct hlist_node node;
    uid_t uid;
};

/* VFS Hook Prototypes */
char *nomount_handle_dpath(const struct path *path, char *buf, int buflen);
int nomount_handle_permission(struct inode *inode, int mask);
struct filename *nomount_handle_getname(struct filename *name);
int nomount_handle_iterate_dir(struct file *file, struct dir_context *ctx);
int nomount_handle_getattr(int ret, const struct path *path, struct kstat *stat);
void nomount_spoof_statfs(const struct path *path, struct kstatfs *buf);
bool nomount_spoof_mmap_metadata(struct inode *inode, dev_t *dev, unsigned long *ino);

/* ========================================================================= */
/* NETLINK GENERIC PROTOCOL DEFINITIONS */
/* ========================================================================= */

#define NOMOUNT_GENL_NAME "nomount"
#define NOMOUNT_GENL_VERSION 1

/* Commands */
enum {
    NOMOUNT_CMD_UNSPEC = 0,
    NOMOUNT_CMD_GET_VERSION,
    NOMOUNT_CMD_ADD_RULE,
    NOMOUNT_CMD_DEL_RULE,
    NOMOUNT_CMD_CLEAR_ALL,
    NOMOUNT_CMD_ADD_UID,
    NOMOUNT_CMD_DEL_UID,
    NOMOUNT_CMD_GET_LIST,
    __NOMOUNT_CMD_MAX,
};
#define NOMOUNT_CMD_MAX (__NOMOUNT_CMD_MAX - 1)

/* Attributes */
enum {
    NOMOUNT_ATTR_UNSPEC = 0,
    NOMOUNT_ATTR_VIRTUAL_PATH,  /* String (NLA_NUL_STRING) */
    NOMOUNT_ATTR_REAL_PATH,     /* String (NLA_NUL_STRING) */
    NOMOUNT_ATTR_FLAGS,         /* u32 (NLA_U32) */
    NOMOUNT_ATTR_UID,           /* u32 (NLA_U32) */
    NOMOUNT_ATTR_VERSION,       /* u32 (NLA_U32) */
    NOMOUNT_ATTR_PAYLOAD,       /* Binary payload for GET_LIST (NLA_BINARY) */
    __NOMOUNT_ATTR_MAX,
};

#define NOMOUNT_ATTR_MAX (__NOMOUNT_ATTR_MAX - 1)

/* * Compat macros for Generic Netlink Policy API changes.
 * Linux 4.20 moved the policy pointer from genl_ops to genl_family.
 */
#if LINUX_VERSION_CODE < KERNEL_VERSION(5, 2, 0)
#define NM_OPS_POLICY(p)    .policy = (p),
#define NM_FAMILY_POLICY(p)
#else
#define NM_OPS_POLICY(p)
#define NM_FAMILY_POLICY(p) .policy = (p),
#endif

/* Application UID start */
#define AID_APP_START 10000

#endif /* _LINUX_NOMOUNT_H */
