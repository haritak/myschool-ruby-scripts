#!/bin/sh
tmux new-session -s artemis -d
tmux send-keys -t artemis 'cd /home/administrator/myschool-ruby-scripts/list-monitoring' C-m
tmux send-keys -t artemis 'ruby processGroupMembers.rb' C-m
tmux new-window -t artemis
tmux send-keys -t artemis 'cd /home/administrator/myschool-ruby-scripts/list-monitoring' C-m
tmux send-keys -t artemis 'while true; do ruby prepareGroups.rb ; ruby waitRandom.rb; done' C-m
tmux new-window -t artemis
tmux send-keys -t artemis 'cd /home/administrator/myschool-ruby-scripts/list-monitoring/efimeries' C-m
tmux send-keys -t artemis 'ruby processEmails.rb' C-m
