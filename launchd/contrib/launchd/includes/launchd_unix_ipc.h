#ifndef __LAUNCHD_UNIX_IPC__
#define __LAUNCHD_UNIX_IPC__
/*
 * Copyright (c) 2005 Apple Computer, Inc. All rights reserved.
 *
 * @APPLE_LICENSE_HEADER_START@
 * 
 * This file contains Original Code and/or Modifications of Original Code
 * as defined in and that are subject to the Apple Public Source License
 * Version 2.0 (the 'License'). You may not use this file except in
 * compliance with the License. Please obtain a copy of the License at
 * http://www.opensource.apple.com/apsl/ and read it before using this
 * file.
 * 
 * The Original Code and all software distributed under the License are
 * distributed on an 'AS IS' basis, WITHOUT WARRANTY OF ANY KIND, EITHER
 * EXPRESS OR IMPLIED, AND APPLE HEREBY DISCLAIMS ALL SUCH WARRANTIES,
 * INCLUDING WITHOUT LIMITATION, ANY WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE, QUIET ENJOYMENT OR NON-INFRINGEMENT.
 * Please see the License for the specific language governing rights and
 * limitations under the License.
 * 
 * @APPLE_LICENSE_HEADER_END@
 */

struct conncb {
	kq_callback kqconn_callback;
	SLIST_ENTRY(conncb) sle;
	launch_t conn;
	struct jobcb *j;
	int disabled_batch:1, futureflags:31;
};

void ipc_open(int fd, struct jobcb *j);
void ipc_close(struct conncb *c);
void ipc_callback(void *, struct kevent *);
void ipc_readmsg(launch_data_t msg, void *context);
void ipc_readmsg2(launch_data_t data, const char *cmd, void *context);
void ipc_revoke_fds(launch_data_t o);
void ipc_close_fds(launch_data_t o);
void ipc_clean_up(void);
void ipc_server_init(void);

#endif
