/*
 * Copyright (c) 2016-2017 Fabrice Bellard
 * Copyright (C) 2018,2019, Esperanto Technologies Inc.
 * Contribution (C) 2024, Jeff Nye
 *
 * Licensed under the Apache License, Version 2.0 (the "License")
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *   http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 * THIS FILE IS BASED ON THE RISCVEMU SOURCE CODE WHICH IS DISTRIBUTED
 * UNDER THE FOLLOWING LICENSE:
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
 * THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

#pragma once
#include "virtio.h"
#include <cstdint>
#include <cstdio>

typedef enum {
    BF_MODE_RO,
    BF_MODE_RW,
    BF_MODE_SNAPSHOT,
} BlockDeviceModeEnum;

typedef struct BlockDeviceFile {
    FILE *              f;
    int64_t             nb_sectors;
    BlockDeviceModeEnum mode;
    uint8_t **          sector_table;
} BlockDeviceFile;

extern int64_t bf_get_sector_count(BlockDevice *bs);

extern int bf_read_async(BlockDevice *bs, uint64_t sector_num, uint8_t *buf, 
                         int n, BlockDeviceCompletionFunc *cb, void *opaque);

extern int bf_write_async(BlockDevice *bs, uint64_t sector_num, 
                         const uint8_t *buf, int n,
                         BlockDeviceCompletionFunc *cb, void *opaque) ;

extern BlockDevice *block_device_init(const char *filename,
                         BlockDeviceModeEnum mode);
