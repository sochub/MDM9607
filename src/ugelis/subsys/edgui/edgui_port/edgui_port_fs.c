/**
 * @file edgui_port_fs_templ.c
 *
 */

 /*Copy this file as "edgui_port_fs.c" and set this value to "1" to enable content*/
#if 0

/*********************
 *      INCLUDES
 *********************/
#include "edgui_port_fs.h"

/*********************
 *      DEFINES
 *********************/

/**********************
 *      TYPEDEFS
 **********************/

/* Create a type to store the required data about your file.
 * If you are using a File System library
 * it already should have a File type.
 * For example FatFS has `FIL`. In this case use `typedef FIL file_t`*/
typedef struct {
    /*Add the data you need to store about a file*/
    uint32_t dummy1;
    uint32_t dummy2;
}file_t;

/*Similarly to `file_t` create a type for directory reading too */
typedef struct {
    /*Add the data you need to store about directory reading*/
    uint32_t dummy1;
    uint32_t dummy2;
}dir_t;


/**********************
 *  STATIC PROTOTYPES
 **********************/
static void fs_init(void);

static edgui_fs_res_t fs_open (edgui_fs_drv_t * drv, void * file_p, const char * path, edgui_fs_mode_t mode);
static edgui_fs_res_t fs_close (edgui_fs_drv_t * drv, void * file_p);
static edgui_fs_res_t fs_read (edgui_fs_drv_t * drv, void * file_p, void * buf, uint32_t btr, uint32_t * br);
static edgui_fs_res_t fs_write(edgui_fs_drv_t * drv, void * file_p, const void * buf, uint32_t btw, uint32_t * bw);
static edgui_fs_res_t fs_seek (edgui_fs_drv_t * drv, void * file_p, uint32_t pos);
static edgui_fs_res_t fs_size (edgui_fs_drv_t * drv, void * file_p, uint32_t * size_p);
static edgui_fs_res_t fs_tell (edgui_fs_drv_t * drv, void * file_p, uint32_t * pos_p);
static edgui_fs_res_t fs_remove (edgui_fs_drv_t * drv, const char *path);
static edgui_fs_res_t fs_trunc (edgui_fs_drv_t * drv, void * file_p);
static edgui_fs_res_t fs_rename (edgui_fs_drv_t * drv, const char * oldname, const char * newname);
static edgui_fs_res_t fs_free (edgui_fs_drv_t * drv, uint32_t * total_p, uint32_t * free_p);
static edgui_fs_res_t fs_dir_open (edgui_fs_drv_t * drv, void * rddir_p, const char *path);
static edgui_fs_res_t fs_dir_read (edgui_fs_drv_t * drv, void * rddir_p, char *fn);
static edgui_fs_res_t fs_dir_close (edgui_fs_drv_t * drv, void * rddir_p);

/**********************
 *  STATIC VARIABLES
 **********************/

/**********************
 * GLOBAL PROTOTYPES
 **********************/

/**********************
 *      MACROS
 **********************/

/**********************
 *   GLOBAL FUNCTIONS
 **********************/

void edgui_port_fs_init(void)
{
    /*----------------------------------------------------
     * Initialize your storage device and File System
     * -------------------------------------------------*/
    fs_init();

    /*---------------------------------------------------
     * Register the file system interface  in edgui
     *--------------------------------------------------*/

    /* Add a simple drive to open images */
    edgui_fs_drv_t fs_drv;                         /*A driver descriptor*/
    memset(&fs_drv, 0, sizeof(edgui_fs_drv_t));    /*Initialization*/

    /*Set up fields...*/
    fs_drv.file_size = sizeof(file_t);
    fs_drv.letter = 'P';
    fs_drv.open = fs_open;
    fs_drv.close = fs_close;
    fs_drv.read = fs_read;
    fs_drv.write = fs_write;
    fs_drv.seek = fs_seek;
    fs_drv.tell = fs_tell;
    fs_drv.free = fs_free;
    fs_drv.size = fs_size;
    fs_drv.remove = fs_remove;
    fs_drv.rename = fs_rename;
    fs_drv.trunc = fs_trunc;

    fs_drv.rddir_size = sizeof(dir_t);
    fs_drv.dir_close = fs_dir_close;
    fs_drv.dir_open = fs_dir_open;
    fs_drv.dir_read = fs_dir_read;

    edgui_fs_add_drv(&fs_drv);
}

/**********************
 *   STATIC FUNCTIONS
 **********************/

/* Initialize your Storage device and File system. */
static void fs_init(void)
{
    /*E.g. for FatFS initalize the SD card and FatFS itself*/

    /*You code here*/
}

/**
 * Open a file
 * @param drv pointer to a driver where this function belongs
 * @param file_p pointer to a file_t variable
 * @param path path to the file beginning with the driver letter (e.g. S:/folder/file.txt)
 * @param mode read: FS_MODE_RD, write: FS_MODE_WR, both: FS_MODE_RD | FS_MODE_WR
 * @return EDGUI_FS_RES_OK or any error from edgui_fs_res_t enum
 */
static edgui_fs_res_t fs_open (edgui_fs_drv_t * drv, void * file_p, const char * path, edgui_fs_mode_t mode)
{
    edgui_fs_res_t res = EDGUI_FS_RES_NOT_IMP;

    if(mode == EDGUI_FS_MODE_WR)
    {
        /*Open a file for write*/

        /* Add your code here*/
    }
    else if(mode == EDGUI_FS_MODE_RD)
    {
        /*Open a file for read*/

        /* Add your code here*/
    }
    else if(mode == (EDGUI_FS_MODE_WR | EDGUI_FS_MODE_RD))
    {
        /*Open a file for read and write*/

        /* Add your code here*/
    }

    return res;
}


/**
 * Close an opened file
 * @param drv pointer to a driver where this function belongs
 * @param file_p pointer to a file_t variable. (opened with edgui_ufs_open)
 * @return EDGUI_FS_RES_OK: no error, the file is read
 *         any error from edgui_fs_res_t enum
 */
static edgui_fs_res_t fs_close (edgui_fs_drv_t * drv, void * file_p)
{
    edgui_fs_res_t res = EDGUI_FS_RES_NOT_IMP;

    /* Add your code here*/

    return res;
}

/**
 * Read data from an opened file
 * @param drv pointer to a driver where this function belongs
 * @param file_p pointer to a file_t variable.
 * @param buf pointer to a memory block where to store the read data
 * @param btr number of Bytes To Read
 * @param br the real number of read bytes (Byte Read)
 * @return EDGUI_FS_RES_OK: no error, the file is read
 *         any error from edgui_fs_res_t enum
 */
static edgui_fs_res_t fs_read (edgui_fs_drv_t * drv, void * file_p, void * buf, uint32_t btr, uint32_t * br)
{
    edgui_fs_res_t res = EDGUI_FS_RES_NOT_IMP;

    /* Add your code here*/

    return res;
}

/**
 * Write into a file
 * @param drv pointer to a driver where this function belongs
 * @param file_p pointer to a file_t variable
 * @param buf pointer to a buffer with the bytes to write
 * @param btr Bytes To Write
 * @param br the number of real written bytes (Bytes Written). NULL if unused.
 * @return EDGUI_FS_RES_OK or any error from edgui_fs_res_t enum
 */
static edgui_fs_res_t fs_write(edgui_fs_drv_t * drv, void * file_p, const void * buf, uint32_t btw, uint32_t * bw)
{
    edgui_fs_res_t res = EDGUI_FS_RES_NOT_IMP;

    /* Add your code here*/

    return res;
}

/**
 * Set the read write pointer. Also expand the file size if necessary.
 * @param drv pointer to a driver where this function belongs
 * @param file_p pointer to a file_t variable. (opened with edgui_ufs_open )
 * @param pos the new position of read write pointer
 * @return EDGUI_FS_RES_OK: no error, the file is read
 *         any error from edgui_fs_res_t enum
 */
static edgui_fs_res_t fs_seek (edgui_fs_drv_t * drv, void * file_p, uint32_t pos)
{
    edgui_fs_res_t res = EDGUI_FS_RES_NOT_IMP;

    /* Add your code here*/

    return res;
}

/**
 * Give the size of a file bytes
 * @param drv pointer to a driver where this function belongs
 * @param file_p pointer to a file_t variable
 * @param size pointer to a variable to store the size
 * @return EDGUI_FS_RES_OK or any error from edgui_fs_res_t enum
 */
static edgui_fs_res_t fs_size (edgui_fs_drv_t * drv, void * file_p, uint32_t * size_p)
{
    edgui_fs_res_t res = EDGUI_FS_RES_NOT_IMP;

    /* Add your code here*/

    return res;
}
/**
 * Give the position of the read write pointer
 * @param drv pointer to a driver where this function belongs
 * @param file_p pointer to a file_t variable.
 * @param pos_p pointer to to store the result
 * @return EDGUI_FS_RES_OK: no error, the file is read
 *         any error from edgui_fs_res_t enum
 */
static edgui_fs_res_t fs_tell (edgui_fs_drv_t * drv, void * file_p, uint32_t * pos_p)
{
    edgui_fs_res_t res = EDGUI_FS_RES_NOT_IMP;

    /* Add your code here*/

    return res;
}

/**
 * Delete a file
 * @param drv pointer to a driver where this function belongs
 * @param path path of the file to delete
 * @return  EDGUI_FS_RES_OK or any error from edgui_fs_res_t enum
 */
static edgui_fs_res_t fs_remove (edgui_fs_drv_t * drv, const char *path)
{
    edgui_fs_res_t res = EDGUI_FS_RES_NOT_IMP;

    /* Add your code here*/

    return res;
}

/**
 * Truncate the file size to the current position of the read write pointer
 * @param drv pointer to a driver where this function belongs
 * @param file_p pointer to an 'ufs_file_t' variable. (opened with edgui_fs_open )
 * @return EDGUI_FS_RES_OK: no error, the file is read
 *         any error from edgui_fs_res_t enum
 */
static edgui_fs_res_t fs_trunc (edgui_fs_drv_t * drv, void * file_p)
{
    edgui_fs_res_t res = EDGUI_FS_RES_NOT_IMP;

    /* Add your code here*/

    return res;
}

/**
 * Rename a file
 * @param drv pointer to a driver where this function belongs
 * @param oldname path to the file
 * @param newname path with the new name
 * @return EDGUI_FS_RES_OK or any error from 'fs_res_t'
 */
static edgui_fs_res_t fs_rename (edgui_fs_drv_t * drv, const char * oldname, const char * newname)
{
    edgui_fs_res_t res = EDGUI_FS_RES_NOT_IMP;

    /* Add your code here*/

    return res;
}

/**
 * Get the free and total size of a driver in kB
 * @param drv pointer to a driver where this function belongs
 * @param letter the driver letter
 * @param total_p pointer to store the total size [kB]
 * @param free_p pointer to store the free size [kB]
 * @return EDGUI_FS_RES_OK or any error from edgui_fs_res_t enum
 */
static edgui_fs_res_t fs_free (uint32_t * total_p, uint32_t * free_p)
{
    edgui_fs_res_t res = EDGUI_FS_RES_NOT_IMP;

    /* Add your code here*/

    return res;
}

/**
 * Initialize a 'fs_read_dir_t' variable for directory reading
 * @param drv pointer to a driver where this function belongs
 * @param rddir_p pointer to a 'fs_read_dir_t' variable
 * @param path path to a directory
 * @return EDGUI_FS_RES_OK or any error from edgui_fs_res_t enum
 */
static edgui_fs_res_t fs_dir_open (edgui_fs_drv_t * drv, void * rddir_p, const char *path)
{
    edgui_fs_res_t res = EDGUI_FS_RES_NOT_IMP;

    /* Add your code here*/

    return res;
}

/**
 * Read the next filename form a directory.
 * The name of the directories will begin with '/'
 * @param drv pointer to a driver where this function belongs
 * @param rddir_p pointer to an initialized 'fs_read_dir_t' variable
 * @param fn pointer to a buffer to store the filename
 * @return EDGUI_FS_RES_OK or any error from edgui_fs_res_t enum
 */
static edgui_fs_res_t fs_dir_read (edgui_fs_drv_t * drv, void * rddir_p, char *fn)
{
    edgui_fs_res_t res = EDGUI_FS_RES_NOT_IMP;

    /* Add your code here*/

    return res;
}

/**
 * Close the directory reading
 * @param drv pointer to a driver where this function belongs
 * @param rddir_p pointer to an initialized 'fs_read_dir_t' variable
 * @return EDGUI_FS_RES_OK or any error from edgui_fs_res_t enum
 */
static edgui_fs_res_t fs_dir_close (edgui_fs_drv_t * drv, void * rddir_p)
{
    edgui_fs_res_t res = EDGUI_FS_RES_NOT_IMP;

    /* Add your code here*/

    return res;
}

#else /* Enable this file at the top */

/* This dummy typedef exists purely to silence -Wpedantic. */
typedef int keep_pedantic_happy;
#endif
