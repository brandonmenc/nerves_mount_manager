#include <err.h>
#include <errno.h>
#include <fcntl.h>
#include <poll.h>
#include <signal.h>
#include <stdio.h>
#include <stdlib.h>

int fd;
FILE *fp;

static void output_file(void)
{
	rewind(fp);
	int c;
	while ((c = fgetc(fp)) != EOF)
		putchar(c);
	fflush(stdout);
}

static void sig_handler(int signo)
{
	if (signo == SIGUSR1)
		output_file();
}

int main(int argc, char *argv[])
{
	(void) argc;
	(void) argv;

	fd = open("/proc/mounts", O_RDONLY, 0);
	if (fd == -1)
		err(1, NULL);

	fp = fdopen(fd, "r");
	if (!fp)
		err(1, NULL);

	if (signal(SIGUSR1, sig_handler) == SIG_ERR)
		err(1, NULL);

	for (;;) {
		struct pollfd fds;

		fds.fd = fd;
		fds.events = POLLPRI;
		fds.revents = 0;

		int rc = poll(&fds, 1, -1);

		if (rc < 0) {
			if (errno == EINTR)
				continue;

			err(EXIT_FAILURE, "poll");
		}

		if (fds.revents & POLLPRI)
			output_file();

		if (fds.revents & (POLLIN | POLLHUP))
			break;
	}

	return 0;
}

