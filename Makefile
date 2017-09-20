# Copyright 2017 Eddie Antonio Santos <easantos@ualberta.ca>
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# Augment path wih applications in ./bin/
PATH := $(PWD)/bin:$(PATH)

# Use parameters from Bhatia and Singh 2016
CONTEXT = 20  # Window size of 10
HIDDEN_LAYERS = 300

# How many files to train on
TRAIN_SET_SIZE := 11000  # files
VALIDATION_SET_SIZE := 5500  # files
TEST_SET_SIZE := $(TRAIN_SET_SIZE)

# Always use the GNU versions of shuf(1) and split(1)
# shuf(1) isn't installed as `shuf` on all systems (e.g., macOS...)
SHUF = $(shell which shuf || which gshuf)

# Make settings
# See: https://www.gnu.org/software/make/manual/html_node/Special-Targets.html
.PHONY: all
.SECONDARY:

all: models

# This will include a LOT of rules to make models, mutations, and results.
include extra-rules.mk
# So many in fact, I've written a script to generate all the rules.
%.mk: %.pl
	perl $< > $@

################################################################################

# When a language is active (see bin/shell),
# allow the generation of the active language's vocabulary using:
#
#  	make vocabulary
#
ifdef SENSIBILITY_LANGUAGE
VOCABULARY := sensibility/language/$(shell language-id)/vocabulary.json
# GNU parallel's --pipepart requires a seekable file, so dump the elligible
# sources in this temporary file:
HASHES_FILE := $(shell mktemp -u hashes.XXXXX)
$(VOCABULARY):
	list-eligible-sources > $(HASHES_FILE)
	parallel --pipepart --round-robin -a $(HASHES_FILE)\
		discover-vocabulary | sort -u | list-to-json > $@
vocabulary: $(VOCABULARY)
.PHONY: vocabulary
endif


# Josh is a phony
.PHONY: joshua
joshua: training.squashfs all-mistakes.squashfs

%.squashfs: %
	mksquashfs $< $@ -comp xz

training: $(addprefix training/,java python javascript)

training/%: %-sources.sqlite3
	bin/joshify $@ $<

mistakes:
	bin/create-mistake-test-set $(TRAIN_SET_SIZE) $@

all-mistakes:
	bin/all-mistakes $@
