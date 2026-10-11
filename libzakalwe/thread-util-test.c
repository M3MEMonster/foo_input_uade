#include <zakalwe/base.h>
#include <zakalwe/next/thread.h>

#include <pthread.h>
#include <stdio.h>
#include <unistd.h>

static int test_value;

struct finish_status {
	pthread_mutex_t mutex;
	int success;
	size_t completed;
	size_t num_items;
	struct task_runner *tr; /* to kick of new tasks */
	pthread_mutex_t cnt_mutex;
	size_t cnt;
	pthread_mutex_t cnt_finish_mutex[4];
};

static int run_0(void *data, size_t i, size_t n, void *ctx)
{
	(void) i;
	z_assert(data == NULL);
	z_assert(ctx == ((void *) &test_value));
	z_assert(n == 4);
	return 1;
}

static int run_empty(void *data, size_t i, size_t n, void *ctx)
{
	(void) data;
	(void) i;
	(void) n;
	(void) ctx;
	return 1;
}

static int run_finish_3(void *data, size_t i, size_t n, void *ctx)
{
	z_assert(data == NULL);
	z_assert(ctx == ((void *) &test_value));
	z_assert(n == 1000);
	return i < 3;
}

static void thread_util_test_0(void)
{
	struct task_runner *tr = task_runner_create(1, TASK_RUNNER_DEFAULT);
	size_t completed;
	size_t n = 4;
	z_assert(tr != NULL);
	z_assert(task_runner_get_num_threads(tr) == 1);
	completed = 0;
	z_assert(task_runner_run_sync(&completed, tr, NULL, n,
				    run_0, &test_value));
	z_assert(completed == n);

	completed = 0;
	z_assert(task_runner_run_sync(&completed, tr, NULL, 1000, run_finish_3,
				    &test_value));
	z_assert(completed >= 4 && completed < 1000);

	completed = -1;
	z_assert(task_runner_run_sync(&completed,tr, NULL, 0,
				    run_0, &test_value));
	z_assert(completed == 0);
	task_runner_free(tr);
}

static void thread_util_test_1(void)
{
	struct task_runner *tr = task_runner_create(0, TASK_RUNNER_DEFAULT);
	size_t completed;
	size_t n = 4;
	z_assert(tr != NULL);

	completed = 0;
	z_assert(task_runner_run_sync(&completed, tr, NULL, n,
				    run_0, &test_value));
	z_assert(completed == n);

	completed = 0;
	z_assert(task_runner_run_sync(&completed, tr, NULL, 0,
				    run_0, &test_value));
	z_assert(completed == 0);

	task_runner_free(tr);
}

static void thread_util_test_2(void)
{
	struct task_runner *tr = task_runner_create(0, TASK_RUNNER_DEFAULT);
	size_t completed;
	size_t i;
	size_t n = 4;
	z_assert(tr != NULL);
	for (i = 0; i < 100; i++) {
		completed = 0;
		z_assert(task_runner_run_sync(&completed, tr, NULL, n,
					    run_0, &test_value));
		z_assert(completed == n);

		completed = -1;
		z_assert(task_runner_run_sync(&completed, tr, NULL, 0, run_0,
					    &test_value));
		z_assert(completed == 0);
	}
	task_runner_free(tr);
}

static void thread_util_benchmark_0(void)
{
	struct task_runner *tr = task_runner_create(4, TASK_RUNNER_DEFAULT);
	size_t completed;
	size_t i;
	size_t n = 1;
	z_assert(tr != NULL);
	for (i = 0; i < 1; i++) {
		completed = 0;
		z_assert(task_runner_run_sync(&completed, tr, NULL, n, run_empty,
					    &test_value));
		z_assert(completed == n);
	}
	task_runner_free(tr);
}

static void done_unlock_mutex(int success, void *data, size_t completed,
			      size_t num_items, void *_struct_finish_status)
{
	struct finish_status *status = _struct_finish_status;
	(void) data;
	status->success = success;
	status->completed = completed;
	status->num_items = num_items;
	z_assert(pthread_mutex_unlock(&status->mutex) == 0);
}

static void task_runner_run_async_test_0(void)
{
	struct task_runner *tr = task_runner_create(1, TASK_RUNNER_DEFAULT);
	size_t n = 4;
	struct finish_status status = {
		.success = 0,
	};

	z_assert(tr != NULL);
	z_assert(task_runner_get_num_threads(tr) == 1);
	z_assert(pthread_mutex_init(&status.mutex, NULL) == 0);

	z_assert(pthread_mutex_lock(&status.mutex) == 0);
	status.completed = 0;
	z_assert(task_runner_run_async(tr, NULL, n, run_empty, NULL,
				     done_unlock_mutex, &status));
	z_assert(pthread_mutex_lock(&status.mutex) == 0);
	z_assert(status.success);
	z_assert(status.completed == status.num_items);
	z_assert(status.completed == n);
	z_assert(pthread_mutex_unlock(&status.mutex) == 0);

	z_assert(pthread_mutex_lock(&status.mutex) == 0);
	status.completed = 0;
	z_assert(task_runner_run_async(tr, NULL, 1000, run_finish_3, &test_value,
				     done_unlock_mutex, &status));
	z_assert(pthread_mutex_lock(&status.mutex) == 0);
	z_assert(status.success);
	z_assert(status.completed >= 4 && status.completed < 1000);
	z_assert(pthread_mutex_unlock(&status.mutex) == 0);


	z_assert(pthread_mutex_lock(&status.mutex) == 0);
	status.completed = 0;
	z_assert(task_runner_run_async(tr, NULL, 0, run_0, &test_value,
				     done_unlock_mutex, &status));
	z_assert(pthread_mutex_lock(&status.mutex) == 0);
	z_assert(status.success);
	z_assert(status.completed == 0);
	z_assert(pthread_mutex_unlock(&status.mutex) == 0);

	task_runner_free(tr);
}

static void task_runner_run_async_test_1(void)
{
	struct task_runner *tr = task_runner_create(4, TASK_RUNNER_DEFAULT);
	size_t completed;
	size_t i;
	size_t n = 4;
	struct finish_status status = {
		.success = 0,
	};

	z_assert(tr != NULL);
	z_assert(pthread_mutex_init(&status.mutex, NULL) == 0);

	for (i = 0; i < 10; i++) {
		z_assert(pthread_mutex_lock(&status.mutex) == 0);
		status.completed = 0;
		z_assert(task_runner_run_async(tr, NULL, n, run_0, &test_value,
					     done_unlock_mutex, &status));
		z_assert(pthread_mutex_lock(&status.mutex) == 0);
		z_assert(status.success);
		z_assert(status.completed == n);
		z_assert(pthread_mutex_unlock(&status.mutex) == 0);

		completed = -1;
		z_assert(task_runner_run_sync(&completed, tr, NULL, 0, run_0,
					    &test_value));
		z_assert(completed == 0);
	}
	task_runner_free(tr);
}

static int run_increase_cnt(void *data, size_t i, size_t num_items,
			    void *_struct_finish_status)
{
	struct finish_status *status = _struct_finish_status;
	(void) data;
	(void) i;
	z_assert(pthread_mutex_lock(&status->cnt_mutex) == 0);
	z_assert(num_items == 4);
	status->cnt++;
	z_assert(pthread_mutex_unlock(&status->cnt_mutex) == 0);
	return 1;
}

static void done_unlock_mutex2(int success, void *data, size_t completed,
			       size_t num_items, void *_pthread_mutex_t)
{
	pthread_mutex_t *mutex = _pthread_mutex_t;
	z_assert(success);
	(void) data;
	(void) completed;
	(void) num_items;
	z_assert(pthread_mutex_unlock(mutex) == 0);
}

static int run_spawn(void *data, size_t i, size_t num_items,
		     void *_struct_finish_status)
{
	struct finish_status *status = _struct_finish_status;
	(void) data;
	(void) num_items;
	z_assert(i < 4);
	z_assert(task_runner_run_async(status->tr, NULL, 4,
				     run_increase_cnt, status,
				     done_unlock_mutex2,
				     &status->cnt_finish_mutex[i]));
	return 1;
}

static void task_runner_run_async_test_2(void)
{
	struct task_runner *tr = task_runner_create(1, TASK_RUNNER_DEFAULT);
	size_t n = 4;
	struct finish_status status = {
		.success = 0,
	};
	size_t i;
	z_assert(tr != NULL);
	z_assert(pthread_mutex_init(&status.mutex, NULL) == 0);
	z_assert(pthread_mutex_init(&status.cnt_mutex, NULL) == 0);

	for (i = 0; i < 4; i++) {
		z_assert(pthread_mutex_init(&status.cnt_finish_mutex[i],
					  NULL) == 0);
		z_assert(pthread_mutex_lock(&status.cnt_finish_mutex[i]) == 0);
	}

	z_assert(pthread_mutex_lock(&status.mutex) == 0);
	status.completed = 0;
	status.tr = tr;
	status.cnt = 0;
	z_assert(task_runner_run_async(tr, NULL, n, run_spawn, &status,
				     done_unlock_mutex, &status));
	z_assert(pthread_mutex_lock(&status.mutex) == 0);

	for (i = 0; i < 4; i++) {
		z_assert(pthread_mutex_lock(&status.cnt_finish_mutex[i]) == 0);
		z_assert(pthread_mutex_unlock(&status.cnt_finish_mutex[i]) == 0);
		z_assert(pthread_mutex_destroy(&status.cnt_finish_mutex[i]) == 0);
	}

	z_assert(status.success);
	z_assert(status.completed == status.num_items);
	z_assert(status.completed == n);
	z_assert(status.cnt == (n * 4));
	z_assert(pthread_mutex_unlock(&status.mutex) == 0);

	task_runner_free(tr);
}

int main(void)
{
	thread_util_test_0();
	thread_util_test_1();
	thread_util_test_2();
	thread_util_benchmark_0();
	task_runner_run_async_test_0();
	task_runner_run_async_test_1();
	task_runner_run_async_test_2();
	return 0;
}
