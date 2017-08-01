#!/usr/bin/env python3
# -*- coding: UTF-8 -*-
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

import pytest

from sensibility.language import language
from sensibility.edit import Insertion, Deletion, Substitution
from sensibility.vocabulary import Vocabulary, Vind
from sensibility.print_edit import print_edit


def setup():
    language.set_language('java')


def test_delete() -> None:
    source_code = b"""
    class Hello {
        }
    }
    """
    edit = Deletion(3, to_index('}'))
    assert print_edit(source_code, edit) == b"""
    class Hello {

    }
    """


def to_index(text: str) -> Vind:
    return language.vocabulary.to_index(text)