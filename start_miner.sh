#!/bin/bash
export GPU_FORCE_64BIT_PTR=1
export GPU_USE_SYNC_OBJECTS=1
export GPU_MAX_ALLOC_PERCENT=100
export GPU_SINGLE_ALLOC_PERCENT=100
export GPU_MAX_HEAP_SIZE=100
(cd /home/rigx/elixir_xmr/; tmux new-session -d -s "elixir_xmr")
tmux send-keys -t "elixir_xmr" "./xmr-stak" Enter
tmux attach -t "elixir_xmr"





