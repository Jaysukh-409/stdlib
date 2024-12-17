#/
# @license Apache-2.0
#
# Copyright (c) 2024 The Stdlib Authors.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#/

# VARIABLES #

# Define the path to the [editorconfig-checker][1] executable.
#
# To install editorconfig-checker:
#
# ```bash
# $ npm install editorconfig-checker
# ```
#
# [1]: https://editorconfig-checker.github.io
EDITORCONFIG_CHECKER ?= $(BIN_DIR)/editorconfig-checker

# Define the path to the editorconfig-checker configuration file:
EDITORCONFIG_CHECKER_CONF ?= $(CONFIG_DIR)/editorconfig-checker/.editorconfig_checker.json

# Define the path to the editorconfig-checker configuration file for Markdown files:
EDITORCONFIG_CHECKER_MARKDOWN_CONF ?= $(CONFIG_DIR)/editorconfig-checker/.editorconfig_checker.markdown.json

# Define the command-line options to use when invoking the editorconfig-checker executable:
EDITORCONFIG_CHECKER_CONF_FLAGS ?= \
	--ignore-defaults


# RULES #

#/
# Lints files to ensure compliance with EditorConfig settings.
#
# @param {string} [PACKAGES_FILTER] - file path pattern (e.g., `.*/math/base/special/abs/.*`)
#
# @example
# make lint-editorconfig
#
# @example
# make lint-editorconfig PACKAGES_FILTER=".*/math/base/special/abs/.*"
#/
lint-editorconfig: $(NODE_MODULES)
	$(QUIET) $(FIND_PACKAGES_CMD) | grep '^[\/]\|^[a-zA-Z]:[/\]' | while read -r pkg; do \
		echo ''; \
		echo "Linting package for basic formatting errors: $$pkg"; \
		cd "$$pkg" && ( $(NODE) $(EDITORCONFIG_CHECKER) $(EDITORCONFIG_CHECKER_CONF_FLAGS) --config $(EDITORCONFIG_CHECKER_CONF) && $(NODE) $(EDITORCONFIG_CHECKER) $(EDITORCONFIG_CHECKER_CONF_FLAGS) --config $(EDITORCONFIG_CHECKER_MARKDOWN_CONF) && echo 'Success. No detected EditorConfig lint errors.' && echo '' ) || exit 1; \
	done

.PHONY: lint-editorconfig

#/
# Lints a specified list of files to ensure compliance with EditorConfig settings.
#
# ## Notes
#
# -   This rule is useful when wanting to lint a list of files generated by some other command (e.g., a list of changed files obtained via `git diff`).
#
# @private
# @param {string} FILES - list of file paths
#
# @example
# make lint-editorconfig-files FILES='foo/test.js bar/index.d.ts'
#/
lint-editorconfig-files: $(NODE_MODULES)
	$(QUIET) $(DELETE) $(DELETE_FLAGS) "$(BUILD_DIR)/editorconfig-checker"
	$(QUIET) echo 'Linting files for basic formatting errors...'
	$(QUIET) $(MKDIR_RECURSIVE) "$(BUILD_DIR)/editorconfig-checker"
	$(QUIET) $(TAR) -cf - $(FILES) | $(TAR) -xf - -C "$(BUILD_DIR)/editorconfig-checker/"
	$(QUIET) cd "$(BUILD_DIR)/editorconfig-checker" && \
		$(NODE) $(EDITORCONFIG_CHECKER) $(EDITORCONFIG_CHECKER_CONF_FLAGS) --config $(EDITORCONFIG_CHECKER_CONF) && \
		$(NODE) $(EDITORCONFIG_CHECKER) $(EDITORCONFIG_CHECKER_CONF_FLAGS) --config $(EDITORCONFIG_CHECKER_MARKDOWN_CONF) && \
		echo 'Success. No detected EditorConfig lint errors.' && \
		echo ''

.PHONY: lint-editorconfig-files
