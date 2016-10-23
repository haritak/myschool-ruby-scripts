#!/bin/sh
tmux new -s artemis -d
tmux send-keys -t artemis 'cd /home/administrator/myschool-ruby-scripts/list-monitoring' C-m
tmux send-keys -t artemis 'ruby processGroupMembers.rb' C-m
tmux send-keys -t artemis C-c 'cd /home/administrator/myschool-ruby-scripts/list-monitoring' C-m
tmux send-keys -t artemis 'while true; do ruby prepareGroups.rb ; echo "waiting";sleep 120; done' C-m
