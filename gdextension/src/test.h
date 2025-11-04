#ifndef TEST_H
#define TEST_H

#include <godot_cpp/classes/node.hpp>
#include <godot_cpp/core/class_db.hpp>
#include <sensors/sensors.h> // lm-sensors

using namespace godot;

class Test : public Node {
    GDCLASS(Test, Node);

protected:
    static void _bind_methods() {
        ClassDB::bind_method(D_METHOD("get_cpu_temps"), &Test::get_cpu_temps);
    }

public:
    Dictionary get_cpu_temps() {
        Dictionary temps;

        if (sensors_init(NULL) != 0) {
            return temps; // failed to initialize
        }

        const sensors_chip_name *chip;
        int chip_nr = 0;
        while ((chip = sensors_get_detected_chips(NULL, &chip_nr)) != NULL) {
            int feature_nr = 0;
            const sensors_feature *feature;
            while ((feature = sensors_get_features(chip, &feature_nr)) != NULL) {
                double val;
                if (sensors_get_value(chip, feature->number, &val) == 0) {
                    temps[feature->name] = val;
                }
            }
        }

        sensors_cleanup();
        return temps;
    }
};

#endif
