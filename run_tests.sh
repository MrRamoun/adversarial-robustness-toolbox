#!/usr/bin/env bash
exit_code=0

# Set TensorFlow logging to minimum level ERROR
export TF_CPP_MIN_LOG_LEVEL="3"

# --------------------------------------------------------------------------------------------------------------- TESTS

pytest -q tests/attacks/evasion/ --mlFramework="tensorflow" --durations=0
if [[ $? -ne 0 ]]; then exit_code=1; echo "Failed attacks/evation tests"; fi

#Only classifier tests need to be run for each frameworks
mlFrameworkList=("tensorflow" "keras" "pytorch" "scikitlearn")
for mlFramework in "${mlFrameworkList[@]}"; do
  echo "Running tests with framework $mlFramework"
  pytest -q tests/classifiersFrameworks/ --mlFramework=$mlFramework --durations=0
  if [[ $? -ne 0 ]]; then exit_code=1; echo "Failed tests for framework $mlFramework"; fi
done


declare -a attacks=("tests/attacks/test_adversarial_patch.py" \
                    "tests/attacks/test_backdoor_attack.py" \
                    "tests/attacks/test_carlini.py" \
                    "tests/attacks/test_copycat_cnn.py" \
                    "tests/attacks/test_decision_tree_attack.py" \
                    "tests/attacks/test_deepfool.py" \
                    "tests/attacks/test_elastic_net.py" \
                    "tests/attacks/test_functionally_equivalent_extraction.py" \
                    "tests/attacks/test_hclu.py" \
                    "tests/attacks/test_input_filter.py" \
                    "tests/attacks/test_hop_skip_jump.py" \
                    "tests/attacks/test_iterative_method.py" \
                    "tests/attacks/test_knockoff_nets.py" \
                    "tests/attacks/test_newtonfool.py" \
                    "tests/attacks/test_poisoning_attack_svm.py" \
                    "tests/attacks/test_projected_gradient_descent.py" \
                    "tests/attacks/test_saliency_map.py" \
                    "tests/attacks/test_spatial_transformation.py" \
                    "tests/attacks/test_universal_perturbation.py" \
                    "tests/attacks/test_virtual_adversarial.py" \
                    "tests/attacks/test_zoo.py" \
                    "tests/attacks/test_pixel_attack.py" \
                    "tests/attacks/test_threshold_attack.py" )

declare -a classifiers=("tests/classifiers/test_blackbox.py" \
                        "tests/classifiers/test_catboost.py" \
                        "tests/classifiers/test_classifier.py" \
                        "tests/classifiers/test_detector_classifier.py" \
                        "tests/classifiers/test_ensemble.py" \
                        "tests/classifiers/test_GPy.py" \
                        "tests/classifiers/test_input_filter.py" \
                        "tests/classifiers/test_keras_tf.py" \
                        "tests/classifiers/test_lightgbm.py" \
                        "tests/classifiers/test_mxnet.py" \
                        "tests/classifiers/test_pytorch.py" \
                        "tests/classifiers/test_scikitlearn.py" \
                        "tests/classifiers/test_xgboost.py" )

declare -a defences=("tests/defences/test_adversarial_trainer.py" \
                     "tests/defences/test_adversarial_trainer_madry_pgd.py" \
                     "tests/defences/test_class_labels.py" \
                     "tests/defences/test_defensive_distillation.py" \
                     "tests/defences/test_feature_squeezing.py" \
                     "tests/defences/test_gaussian_augmentation.py" \
                     "tests/defences/test_gaussian_noise.py" \
                     "tests/defences/test_high_confidence.py" \
                     "tests/defences/test_jpeg_compression.py" \
                     "tests/defences/test_label_smoothing.py" \
                     "tests/defences/test_pixel_defend.py" \
                     "tests/defences/test_reverse_sigmoid.py" \
                     "tests/defences/test_rounded.py" \
                     "tests/defences/test_spatial_smoothing.py" \
                     "tests/defences/test_thermometer_encoding.py" \
                     "tests/defences/test_variance_minimization.py" )

declare -a detection=("tests/detection/subsetscanning/test_detector.py" \
                      "tests/detection/test_detector.py" )

declare -a metrics=("tests/metrics/test_metrics.py" \
                    "tests/metrics/test_verification_decision_trees.py" )

declare -a poison_detection=("tests/poison_detection/test_activation_defence.py" \
                             "tests/poison_detection/test_clustering_analyzer.py" \
                             "tests/poison_detection/test_ground_truth_evaluator.py" \
                             "tests/poison_detection/test_provenance_defence.py" \
                             "tests/poison_detection/test_roni.py" )

declare -a wrappers=("tests/wrappers/test_expectation.py" \
                     "tests/wrappers/test_query_efficient_bb.py" \
                     "tests/wrappers/test_randomized_smoothing.py" \
                     "tests/wrappers/test_wrapper.py" )

declare -a art=("tests/test_data_generators.py" \
                "tests/test_utils.py" \
                "tests/test_visualization.py" )

tests_modules=("attacks" \
               "classifiers" \
               "defences" \
               "detection" \
               "metrics" \
               "poison_detection" \
               "wrappers" \
               "art" )

# --------------------------------------------------------------------------------------------------- CODE TO RUN TESTS

run_test () {
  test=$1
  test_file_name="$(echo ${test} | rev | cut -d'/' -f1 | rev)"

  echo $'\n\n'
  echo "######################################################################"
  echo ${test}
  echo "######################################################################"
  coverage run --append -m unittest -v ${test}
  if [[ $? -ne 0 ]]; then exit_code=1; echo "Failed $test"; fi
}

for tests_module in "${tests_modules[@]}"; do
  tests="$tests_module[@]"
  for test in "${!tests}"; do
     run_test ${test}
  done
done

bash <(curl -s https://codecov.io/bash)

exit ${exit_code}
