/*
 * Test bench for majordomo_cosim A
 *
 * Copyright (C) 2018,2019, Esperanto Technologies Inc.
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
 * Parse the trace output and check that we cosim correctly.
 */
#include "majordomo_cosim.h"
#include "majordomo.h"
#include "options.h"

#include <stdlib.h>
#include <string.h>
#include <unistd.h>

Options *Options::instance = 0;
std::shared_ptr<Options> opts(Options::getInstance());

void usage(char *progname) {
    fprintf(stderr,
            "Usage:\n"
            "  %s cosim $trace $majordomoargs ...\n"
            "  %s read $trace\n",
            progname,
            progname);
    exit(EXIT_FAILURE);
}

int main(int argc, char *argv[]) {
    char *progname  = argv[0];
    bool  cosim     = false;
    int   exit_code = EXIT_SUCCESS;

    majordomo_stdout = stdout;
    majordomo_stderr = stderr;

    if (argc < 3)
        usage(progname);

    char *cmd = argv[1];
    if (strcmp(cmd, "read") == 0)
        cosim = false;
    else if (strcmp(cmd, "cosim") == 0)
        cosim = true;
    else
        usage(progname);

    char *trace_name = argv[2];
    FILE *f          = fopen(trace_name, "r");
    if (!f) {
        perror(trace_name);
        usage(progname);
    }

    majordomo_cosim_state_t *s = NULL;
    if (cosim) {
        /* Prep args for majordomo_cosim_init */
        argc -= 2;
        argv += 2;
        argv[0] = progname;

        s = majordomo_cosim_init(argc, argv);
        if (!s)
            usage(progname);
    }

    for (int lineno = 1; !feof(f); ++lineno) {
        char     buf[99];
        uint64_t insn_addr, wdata;
        uint32_t insn, rd;
        int      priv;
        int      hartid;
        uint64_t tval;
        int      exception;

        if (!fgets(buf, sizeof buf, f))
            break;

        rd        = 0;
        wdata     = 0;
        exception = 0;
        tval      = 0;
        char x_or_f_reg;
        int  got
            = sscanf(buf, "%d %d %" PRIx64 " (0x%x) %c%d 0x%" PRIx64, &hartid, &priv, &insn_addr, &insn, &x_or_f_reg, &rd, &wdata);

        switch (got) {
            case 4:
                fprintf(majordomo_stdout,
                        "%d %d %016" PRIx64 " %08x                           DASM(%08x)\n",
                        hartid,
                        priv,
                        insn_addr,
                        insn,
                        insn);
                break;

            case 5:
                got = sscanf(buf,
                             "%d %d %" PRIx64 " (0x%x) exception %d, tval %" PRIx64,
                             &hartid,
                             &priv,
                             &insn_addr,
                             &insn,
                             &exception,
                             &tval);
                if (got != 6) {
                    fprintf(majordomo_stderr, "%s:%d: expected exception, coult not parse %s\n", trace_name, lineno, buf);
                    goto fail;
                }

                break;

            case 7:
                fprintf(majordomo_stdout,
                        "%d %d %016" PRIx64 " %08x [x%-2d <- %016" PRIx64 "] DASM(%08x)\n",
                        hartid,
                        priv,
                        insn_addr,
                        insn,
                        rd,
                        wdata,
                        insn);
                break;

            default: fprintf(majordomo_stderr, "%s:%d: couldn't parse %s\n", trace_name, lineno, buf); goto fail;

            case 0:
            case -1: continue;
        }

        if (!cosim)
            continue;

        if (exception && (exception < 8 || exception > 11)) {  // do not skip ECALLS
            majordomo_cosim_raise_trap(s, hartid, exception);
            fprintf(majordomo_stdout, "exception %d with tval %08" PRIx64 "\n", exception, tval);
            continue;
        }
        int r = majordomo_cosim_step(s, hartid, insn_addr, insn, wdata, 0, true);
        if (r) {
            fprintf(majordomo_stdout, "Exited with %08x\n", r);
            goto fail;
        }
    }

done:
    if (cosim)
        majordomo_cosim_fini(s);

    if (exit_code == EXIT_SUCCESS)
        fprintf(majordomo_stdout, "\nSUCCESS, PASSED, GOOD!\n");
    else
        fprintf(majordomo_stdout, "\nFAIL!\n");

    if (majordomo_stdout != stdout)
        fclose(majordomo_stdout);

    exit(exit_code);

fail:
    exit_code = EXIT_FAILURE;
    goto done;
}
