#!/usr/bin/env bash

start=$(date +%s%3N)

./C/game

end=$(date +%s%3N)
duration=$((end - start))

echo "Execution time: ${duration} ms"

