//
// Created by alex on 9/5/22.
//

#include <string.h>

#include "types.h"

const char *PA_TYPES_STRING[] = {
        "sink",
        "sink_input",
        "source",
        "source_output",
        "all",
};

enum PA_TYPES_ENUM string_type_to_enum(const char *type) {
    if (strcmp(PA_TYPES_STRING[sink], type) == 0) {
        return sink;
    } else if (strcmp(PA_TYPES_STRING[sink_input], type) == 0) {
        return sink_input;
    } else if (strcmp(PA_TYPES_STRING[source], type) == 0) {
        return source;
    } else if (strcmp(PA_TYPES_STRING[source_output], type) == 0) {
        return source_output;
    } else if (strcmp(PA_TYPES_STRING[all], type) == 0) {
        return all;
    }

    return -1;
}
