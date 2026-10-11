#include <zakalwe/base.h>
#include <zakalwe/unix-support.h>

#include <assert.h>
#include <fcntl.h>
#include <stdio.h>
#include <string.h>
#include <sys/types.h>
#include <sys/wait.h>
#include <unistd.h>

static void test_z_assert_eq(void)
{
	pid_t child;
	int status;
	int test_table[3][3] = {
		{1, 1, 1},
		{1, 2, 0},
		{-1, -1, 0},
	};
	size_t i;
	for (i = 0; test_table[i][0] >= 0; i++) {
		child = fork();
		if (child == 0) {
			int fd = open("/dev/null", O_WRONLY);
			assert(fd >= 0);
			assert(dup2(fd, 2) == 2);
			z_assert_eq(test_table[i][0], test_table[i][1]);
			exit(0);
		} else {
			waitpid(child, &status, 0);
			assert((!!WIFEXITED(status)) == test_table[i][2]);
		}
	}
}

static void test_log(void)
{
	pid_t child;
	int status;
	child = fork();
	if (child == 0) {
		int fd = open("/dev/null", O_WRONLY);
		assert(fd >= 0);
		assert(dup2(fd, 2) == 2);
		z_log_fatal("fatal\n");
		exit(0);
	} else {
		waitpid(child, &status, 0);
		z_assert(WIFEXITED(status) == 0);
	}
}

static void test_log_every_n_secs(void)
{
	pid_t child;
	int status;
	int pipefds[2];
	size_t len;

	z_assert(!pipe(pipefds));
	child = fork();
	if (child == 0) {
		close(pipefds[0]);
		assert(dup2(pipefds[1], 2) == 2);
		z_log_info("i\n");
		z_log_info("i\n");
		exit(0);
	} else {
		char buf[4096];
		char *p;
		close(pipefds[1]);
		waitpid(child, &status, 0);
		z_assert(WIFEXITED(status));

		len = z_atomic_read(pipefds[0], buf, (sizeof(buf) - 1));
		z_assert(len > 0);
		buf[len] = 0;

		p = strchr(buf, '\n');
		z_assert(p != NULL);
		z_assert(strchr(p + 1, '\n') != NULL);
		close(pipefds[0]);
	}

	z_assert(!pipe(pipefds));
	child = fork();
	if (child == 0) {
		close(pipefds[0]);
		assert(dup2(pipefds[1], 2) == 2);
		z_log_info_every_n_secs(10, "i\n");
		z_log_info_every_n_secs(10, "i\n");
		exit(0);
	} else {
		char buf[4096];
		char *p;
		close(pipefds[1]);
		waitpid(child, &status, 0);
		z_assert(WIFEXITED(status));
		len = z_atomic_read(pipefds[0], buf, (sizeof(buf) - 1));
		z_assert(len > 0);
		buf[len] = 0;
		p = strchr(buf, '\n');
		z_assert(p != NULL);
		z_assert(strchr(p + 1, '\n') == NULL);
		close(pipefds[0]);
	}
}

int main(void)
{
	test_z_assert_eq();
	test_log();
	test_log_every_n_secs();
	return 0;
}
