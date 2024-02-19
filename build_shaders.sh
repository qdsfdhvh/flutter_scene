#!/usr/bin/env bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
cd $SCRIPT_DIR
source build_utils.sh

IMPELLERC_EXE="$(GetImpellercExecutable)"
if [ ! -f "$IMPELLERC_EXE" ]; then
    echo "ImpellerC not found. Can't build shader bundle!"
    exit 1
fi

function build_shader {
    echo "Building shader bundle: $1"

    SHADER_BUNDLE_JSON=$(echo $2 | tr -d '\n')
    $IMPELLERC_EXE --sl="$1" --shader-bundle="$SHADER_BUNDLE_JSON"
}

BASE_BUNDLE_JSON='
{
    "SimpleVertex": {
        "type": "vertex",
        "file": "shaders/flutter_scene_simple.vert"
    },
    "SimpleFragment": {
        "type": "fragment",
        "file": "shaders/flutter_scene_simple.frag"
    },
    "UnskinnedVertex": {
        "type": "vertex",
        "file": "shaders/flutter_scene_unskinned.vert"
    },
    "SkinnedVertex": {
        "type": "vertex",
        "file": "shaders/flutter_scene_skinned.vert"
    },
    "UnlitFragment": {
        "type": "fragment",
        "file": "shaders/flutter_scene_unlit.frag"
    }
}'
build_shader "assets/base.shaderbundle" "$BASE_BUNDLE_JSON"
