#!/bin/bash
#
# Copyright (C) 2024 Flakeforever
#
# SPDX-License-Identifier: Apache-2.0
#

base_dir="device/xiaomi/mondrian/patches"

while IFS= read -r -d '' diff_file; do
    diff_filename=$(basename "$diff_file")
    subdir=$(dirname "${diff_file#$base_dir/}")

    result_list+=("$diff_filename|$subdir")
done < <(find "$base_dir" -type f -name "*.diff" -print0 | sort -z)

for result in "${result_list[@]}"; do
    IFS='|' read -r patch_file target_path <<< "$result"
    current_dir=$(realpath .)
    patch_file=$current_dir/$base_dir/$target_path/$patch_file

    target_path=${target_path//_/\/}

#    echo "$patch_file"
#    echo "$target_path"

    git -C "$target_path" apply "$patch_file"
done