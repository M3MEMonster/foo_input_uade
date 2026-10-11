#include <stdio.h>
#include <stdlib.h>
#include <uade/uade.h>

int main(int argc, char **argv)
{
	struct uade_config *config;
	struct uade_state *state;
	unsigned char audio[4096];
	ssize_t bytes;
	long long total_bytes = 0;
	long long nonzero_bytes = 0;
	int first_nonzero_block = -1;
	int block;
	int index;
	int result;

	if (argc != 4) {
		fprintf(stderr, "usage: uade_probe BASEDIR UADECORE MODULE\n");
		return 2;
	}

	config = uade_new_config();
	uade_config_set_option(config, UC_BASE_DIR, argv[1]);
	uade_config_set_option(config, UC_UADECORE_FILE, argv[2]);
	uade_config_set_option(config, UC_NO_CONTENT_DB, NULL);
	uade_config_set_option(config, UC_ONE_SUBSONG, NULL);
	uade_config_set_option(config, UC_VERBOSE, NULL);

	state = uade_new_state(config);
	free(config);
	if (state == NULL) return 3;

	result = uade_play(argv[3], -1, state);
	printf("play=%d\n", result);
	if (result == 1) {
		for (block = 0; block < 1000; ++block) {
			bytes = uade_read(audio, sizeof(audio), state);
			if (bytes <= 0) break;
			total_bytes += bytes;
			for (index = 0; index < bytes; ++index) {
				if (audio[index] != 0) {
					++nonzero_bytes;
					if (first_nonzero_block < 0) first_nonzero_block = block;
				}
			}
		}
		printf("blocks=%d bytes=%lld nonzero=%lld first_nonzero_block=%d last_read=%lld\n",
		       block, total_bytes, nonzero_bytes, first_nonzero_block, (long long)bytes);
	}
	uade_cleanup_state(state);
	return result == 1 ? 0 : 1;
}
