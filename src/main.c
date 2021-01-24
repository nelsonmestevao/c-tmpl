#include <argp.h>
#include <error.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

const char *argp_program_version = "exemplo 0.1.0";
const char *argp_program_bug_address = "hello@estevao.org";

/* Program documentation. */
static char doc[] = "exemplo FIXME";

/* A description of the arguments we accept. */
static char args_doc[] = "ARG1 [STRING...]";

/* The options we understand. */
static struct argp_option options[] = {
    {"verbose", 'v', 0, 0, "Produce verbose output", 0},
    {"quiet", 'q', 0, 0, "Don't produce any output", 0},
    {"silent", 's', 0, OPTION_ALIAS, 0, 0},
    {"output", 'o', "FILE", 0, "Output to FILE instead of standard output", 0},
    {0}};

/* Used by main to communicate with parse_opt. */
struct arguments {
    char *arg1;                 /* arg1 */
    char **strings;             /* [string…] */
    int silent, verbose, abort; /* ‘-s’, ‘-v’, ‘--abort’ */
    char *output_file;          /* file arg to ‘--output’ */
};

/* Parse a single option. */
static error_t parse_opt(int key, char *arg, struct argp_state *state) {
    struct arguments *arguments = state->input;

    switch (key) {
        case 'q':
        case 's':
            arguments->silent = 1;
            break;
        case 'v':
            arguments->verbose = 1;
            break;
        case 'o':
            arguments->output_file = arg;
            break;

        case ARGP_KEY_NO_ARGS:
            argp_usage(state);
            break;

        case ARGP_KEY_ARG:
            /* Here we know that state->arg_num == 0, since we
               force argument parsing to end before any more arguments can
               get here. */
            arguments->arg1 = arg;
            arguments->strings = &state->argv[state->next];
            state->next = state->argc;
            break;

        default:
            return ARGP_ERR_UNKNOWN;
    }

    return 0;
}

/* Our argp parser. */
static struct argp argp = {options, parse_opt, args_doc, doc, NULL, NULL, NULL};

int main(int argc, char **argv) {
    struct arguments arguments;

    /* Default values. */
    arguments.silent = 0;
    arguments.verbose = 0;
    arguments.output_file = "/tmp/file.tmp";
    arguments.abort = 0;

    argp_parse(&argp, argc, argv, 0, 0, &arguments);

    printf("ARG1 = %s\n", arguments.arg1);

    printf("STRINGS = ");
    for (int j = 0; arguments.strings[j]; j++)
        printf(j == 0 ? "%s" : ", %s", arguments.strings[j]);
    printf("\n");

    printf("OUTPUT_FILE = %s\nVERBOSE = %s\nSILENT = %s\n",
           arguments.output_file, arguments.verbose ? "yes" : "no",
           arguments.silent ? "yes" : "no");

    return 0;
}
