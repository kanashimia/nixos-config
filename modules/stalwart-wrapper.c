#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <sys/wait.h>
#include <spawn.h>
#include <errno.h>

extern char **environ;

#define MAX_LINE_SIZE 4096 // 4kb is enough for everyone

int get_syslog_severity(const char *level) {
    if (strcmp(level, "EMERG") == 0)  return 0;
    if (strcmp(level, "ALERT") == 0)  return 1;
    if (strcmp(level, "CRIT") == 0)   return 2;
    if (strcmp(level, "ERR") == 0)    return 3;
    if (strcmp(level, "WARN") == 0)   return 4;
    if (strcmp(level, "NOTICE") == 0) return 5;
    if (strcmp(level, "INFO") == 0)   return 6;
    if (strcmp(level, "DEBUG") == 0)  return 7;
    return -1;
}

void parse_and_print_line(char *line) {
    char timestamp[32];
    char level[16];

    // sscanf extracts timestamp, log level, and gets offset where the message starts
    int offset = 0;
    if (sscanf(line, "%31s %15s %n", timestamp, level, &offset) == 2) {
      char * lvl = level;
        if (lvl[0] == '\x1b' && lvl[1] == '[') {
          lvl += 2;
          while (*lvl && !(*lvl >= '@' && *lvl <= '~')) {
              lvl++;
          }
          if (*lvl) {
              lvl++;
          }
          lvl[strcspn(lvl, "\x1b")] = '\0';
        }
        int severity = get_syslog_severity(lvl);
        char *message = line + offset;
        if (severity != -1) {
          printf("<%d>%s", severity, message);
        } else {
          printf("<6>%s", line);
        }
    } else {
        // Fallback for lines that don't match expected log format
        printf("<6>%s", line);
    }
}

volatile sig_atomic_t child_pid = 0;

// SIGINT Handler Definition
void handle_sigint(int sig) {}

int main(int argc, char *argv[]) {
    if (argc < 2) {
        fprintf(stderr, "Usage: %s <command> [args...]\n", argv[0]);
        return EXIT_FAILURE;
    }

    int pipefd[2];
    if (pipe(pipefd) == -1) {
        perror("pipe");
        return EXIT_FAILURE;
    }

    struct sigaction sa;
    sa.sa_handler = handle_sigint;
    sigemptyset(&sa.sa_mask);
    sa.sa_flags = SA_RESTART;

    // Register the SIGINT handler
    if (sigaction(SIGINT, &sa, NULL) == -1 || sigaction(SIGTERM, &sa, NULL) == -1) {
        perror("sigaction failed");
        return EXIT_FAILURE;
    }

    // --- Prepare posix_spawn file actions ---
    posix_spawn_file_actions_t actions;
    if (posix_spawn_file_actions_init(&actions) != 0) {
        perror("posix_spawn_file_actions_init");
        close(pipefd[0]);
        close(pipefd[1]);
        return EXIT_FAILURE;
    }

    // Close unused read end in child
    posix_spawn_file_actions_addclose(&actions, pipefd[0]);
    // Redirect stdout to pipe write end
    posix_spawn_file_actions_adddup2(&actions, pipefd[1], STDOUT_FILENO);
    posix_spawn_file_actions_adddup2(&actions, pipefd[1], STDERR_FILENO);
    // Close original write end descriptor after dup2
    posix_spawn_file_actions_addclose(&actions, pipefd[1]);

    // --- Spawn Child Process ---
    pid_t pid;
    int status = posix_spawnp(&pid, argv[1], &actions, NULL, &argv[1], environ);
    child_pid = pid;

    // Clean up spawn actions structure
    posix_spawn_file_actions_destroy(&actions);

    if (status != 0) {
        fprintf(stderr, "posix_spawnp failed: %s\n", strerror(status));
        close(pipefd[0]);
        close(pipefd[1]);
        return EXIT_FAILURE;
    }

    // --- Parent Process ---
    close(pipefd[1]); // Close write end in parent

    // Open pipe read end as FILE stream for line-by-line reading
    FILE *stream = fdopen(pipefd[0], "r");
    if (!stream) {
        perror("fdopen");
        close(pipefd[0]);
        return EXIT_FAILURE;
    }

    char *line = NULL;
    size_t len = 0;

    // Read and parse each line until EOF
    char line_buf[MAX_LINE_SIZE] = {};
    while (fgets(line_buf, sizeof(line_buf), stream) != NULL) {
        parse_and_print_line(line_buf);
        fflush(stdout);
    }

    free(line);
    fclose(stream);

    // Wait for child process to finish
    waitpid(pid, &status, 0);

    return EXIT_SUCCESS;
}
