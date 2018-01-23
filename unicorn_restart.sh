#!bash
kill -9 `cat tmp/pids/unicorn.pid`
bundle exec unicorn -E production -c ./config/unicorn.rb &